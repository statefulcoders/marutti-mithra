import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:maruttimitra/configs/local/app_configs.dart';
import 'package:maruttimitra/configs/local/constants.dart';
import 'package:maruttimitra/dialogs/confirmation_dialog.dart';
import 'package:maruttimitra/models/remote/message_model.dart';
import 'package:maruttimitra/utils/extras_table_helper.dart';
import 'package:maruttimitra/utils/message_table_helper.dart';
import 'package:maruttimitra/utils/settings/marutti_settings_memory.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:waveform_recorder/waveform_recorder.dart';

import '../../../overlays/app_snackbar.dart';

class SupportChatController extends GetxController {
  Timer? recordingTimer;
  final String title = Get.parameters[Constants.keyTitle] ?? '';
  final String category = Get.parameters[Constants.keyCategory] ?? '';

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final isSending = false.obs;

  final canSend = false.obs;
  final isRecording = false.obs;
  final waveController = WaveformRecorderController();

  final selectedFile = Rxn<File>();
  String get selectedAudioName => selectedFile.value?.path.split('/').last ?? '';

  final messages = Rxn<List<MessageModel>>();
  final hasMore = true.obs;

  StreamSubscription? messageStream;
  DocumentSnapshot? lastDoc;

  final player = AudioPlayer();
  final isPlaying = false.obs;
  final isAudioSelected = false.obs;
  final isPlayerLoading = false.obs;
  final position = Duration.zero.obs;
  final duration = Duration(milliseconds: 1).obs;

  StreamSubscription? positionStream;
  StreamSubscription? durationStream;
  StreamSubscription? stateStream;

  final currentPlayingAudio = ''.obs;

  final imagePicker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    messageController.addListener(() {
      canSend.value = messageController.text.trim().isNotEmpty;
    });
    messageStream = MessageTableHelper.getMessagesStream(category: category).listen((event) {
      if (messages.value == null) {
        lastDoc = event.docs.lastOrNull;
      } else if (event.docs.length >= MessageTableHelper.messagesLimit) {
        hasMore.value = true;
      }
      messages.value = event.docs.map((e) => MessageModel.fromJson({...(e.data() as Map<String, dynamic>), 'id': e.id})).toList();
    });
    scrollController.addListener(() {
      if (scrollController.position.atEdge &&
          scrollController.position.pixels == scrollController.position.maxScrollExtent &&
          hasMore.value) {
        getMessages();
      }
    });

    positionStream = player.positionStream.listen((event) => position.value = event);
    durationStream = player.durationStream.listen((event) => duration.value = event ?? Duration(milliseconds: 1));
    stateStream = player.playerStateStream.listen((event) {
      switch (event.processingState) {
        case ProcessingState.completed:
          isPlayerLoading.value = false;
          isPlaying.value = false;
          position.value = Duration.zero;
          duration.value = Duration(milliseconds: 1);
          currentPlayingAudio.value = '';
          break;
        case ProcessingState.ready:
          isPlayerLoading.value = false;
          isPlaying.value = event.playing;
          break;
        case ProcessingState.loading:
        case ProcessingState.buffering:
          isPlayerLoading.value = true;
          isPlaying.value = false;
          break;
        case ProcessingState.idle:
          isPlayerLoading.value = false;
          isPlaying.value = false;
          break;
      }
    });

  }

  Future<void> askForFirm() async {
    if (category != MessageTableHelper.categoryOrder) {
      return;
    }

    final shops = [
      'MWholesales',
      'Hardware Palace',
      'Marutti Aluminiums',
      'Vinlam Concepts'
    ];

    final available = MaruttiSettingsMemory.firm;
    final firm = RxnString(available.isEmpty ? shops.first : available);

    final added = await ConfirmationDialog.confirm(
      'In which shop you want to order:',
      title: 'Select Firm',
      centerThings: false,
      positiveLabel: 'continue'.tr,
      negativeLabel: 'cancel'.tr,
      showIcon: false,
      content: Obx(() => Column(
        children: shops.map((e) => RadioListTile<String>(
          contentPadding: EdgeInsets.zero,
          value: e,
          groupValue: firm.value,
          title: Text(
            e,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          onChanged: (choice) => firm.value = choice,
        ))
            .toList(),
      )),
    );

    if (!added) {
      Get.back();
    } else {
      MaruttiSettingsMemory.saveFirmChoice(firm.value ?? '');
    }
  }

  Future<void> getMessages([bool reset = false]) async {
    if (reset) {
      lastDoc = null;
      hasMore.value = true;
    }

    if (!hasMore.value) return;

    try {
      final result = await MessageTableHelper.getMessages(
        category: category,
        startAfter: lastDoc,
      );

      final newDocs = result.docs;

      if (newDocs.isEmpty) {
        hasMore.value = false;
        return;
      }

      lastDoc = newDocs.last;

      final existingIds = (messages.value ?? []).map((m) => m.id).toSet();

      final newMessages = newDocs
          .map((e) => MessageModel.fromJson({...(e.data() as Map<String, dynamic>), 'id': e.id}))
          .where((m) => !existingIds.contains(m.id))
          .toList();

      messages.value = [
        ...(messages.value ?? []),
        ...newMessages,
      ];
    } catch (error) {
      AppSnackBar.error(error.toString());
    }
  }

  Future<void> sendMessage() async {
    String content = messageController.text.trim();

    if (isSending.value || (content.isEmpty && selectedFile.value == null)) {
      return;
    }

    messageController.clear();
    canSend.value = false;
    isRecording.value = false;
    File? audio = selectedFile.value;
    selectedFile.value = null;

    isSending.value = true;

    if (audio != null && isAudioSelected.value) {
      content = '<audio>';
    } else if (audio != null) {
      content = '<image>';
    }

    try {

      if (audio != null && content == '<image>') {
        int sent = await MessageTableHelper.getTodaySentImagesCount();
        final responses = await ExtrasTableHelper.getSupportDetails();
        if (sent > responses.imageLimit) {
          AppSnackBar.error('You can only send ${responses.imageLimit} images per day. Please try again tomorrow.');
          return;
        }
      }

      await MessageTableHelper.addMessage(category: category, content: content.isEmpty ? null : content, audioFile: audio);
      await audio?.delete();
    } catch (error) {
      AppSnackBar.error(error.toString());
    } finally {
      isSending.value = false;
    }
  }

  Future<void> toggleRecording() async {
    final permission = await Permission.microphone.request();

    if (permission.isPermanentlyDenied) {
      AppSnackBar.error('Microphone permission permanently denied. Please enable it from app settings.');
      await openAppSettings();
      return;
    }

    if (!permission.isGranted) {
      AppSnackBar.error('Please grant microphone permission to record audio.');
      return;
    }
    recordingTimer?.cancel();
    if (waveController.isRecording) {
      await waveController.stopRecording();
      isRecording.value = false;
    } else {
      selectedFile.value = null;
      await waveController.startRecording();
      isRecording.value = true;
      // Automatically stop recording after 5 minutes
      recordingTimer = Timer(AppConfig.recordingDuration, () async {
        if (waveController.isRecording) {
          await waveController.stopRecording();
          isRecording.value = false;
        }
      });
    }
  }

  Future<void> onRecordingStopped() async {
    final file = waveController.file;
    if (file == null) return;

    isAudioSelected.value = true;
    selectedFile.value = File(file.path);
  }

  Future<void> discardRecording() async {
    await selectedFile.value?.delete();
    selectedFile.value = null;
  }

  Future<void> startPlayer(String url) async {
    try {
      await player.pause();
      isPlaying.value = false;
    } catch (_) {}
    currentPlayingAudio.value = url;
    try {
      await player.setUrl(url);
      await player.play();
      isPlaying.value = true;
    } catch (e) {
      print("PLAYER ERROR ->> ${e}");
      AppSnackBar.error(e.toString());
    }
  }

  Future<void> resumePlayer() async {
    try {
      await player.play();
      isPlaying.value = true;
    } catch (_) {}
  }

  Future<void> pausePlayer() async {
    try {
      await player.pause();
      isPlaying.value = false;
    } catch (_) {}
  }

  Future<void> seekPlayer(Duration position) async {
    try {
      await player.seek(position);
    } catch (_) {}
  }

  Future<void> chooseImage() async {
    try {
      final image = await imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final file = File(image.path);
        final sizeInMB = (await file.length()) / (1024 * 1024);
        if (sizeInMB > AppConfig.imageSizeLimitInMB) {
          AppSnackBar.error('Image size exceeds limit of ${AppConfig.imageSizeLimitInMB} MB');
          return;
        }
        isAudioSelected.value = false;
        selectedFile.value = file;
      }
    } catch (e) {
      AppSnackBar.error(e.toString());
    }
  }

  @override
  void onClose() {
    recordingTimer?.cancel();
    messageStream?.cancel();
    durationStream?.cancel();
    positionStream?.cancel();
    stateStream?.cancel();
    messageController.dispose();
    scrollController.dispose();
    waveController.dispose();
    player.dispose();
    super.onClose();
  }
}