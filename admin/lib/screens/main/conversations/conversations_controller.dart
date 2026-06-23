import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marutti_mitra_admin/helpers/firebase/push_notifications_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:waveform_recorder/waveform_recorder.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:html' as html;
import 'dart:typed_data';

import '../../../comlate/data/configs/app_config.dart';
import '../../../comlate/overlays/app_snackbar.dart';

class ConversationsController extends GetxController {
  Timer? recordingTimer;

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final isSending = false.obs;

  final canSend = false.obs;
  final isRecording = false.obs;
  final waveController = WaveformRecorderController();

  final selectedFile = Rxn<XFile>();
  String get selectedAudioName => selectedFile.value?.path.split('/').last ?? '';

  final messages = Rxn<List<Map<String, dynamic>>>();
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

  final imagePicker = FilePicker.platform;

  final Map<String, dynamic> userData;
  final String type;
  final limit = 16;

  String get uid => userData['uid'] ?? '';
  String get username => userData['username'] ?? '';
  String get firebaseToken => userData['firebaseToken'] ?? '';

  ConversationsController({ required this.userData, required this.type });

  @override
  void onInit() {
    super.onInit();
    messageController.addListener(() {
      canSend.value = messageController.text.trim().isNotEmpty;
    });
    Query query = FirebaseFirestore.instance.collection('messages').doc(uid).collection(type);
    if (userData['shop_filter'] != null) {
      query = query.where('orderFrom', isEqualTo: userData['shop_filter']);
    }
    messageStream = query.orderBy('createdAt', descending: true).limit(limit).snapshots().listen((event) {
      if (messages.value == null) {
        lastDoc = event.docs.lastOrNull;
      } else if (event.docs.length >= limit) {
        hasMore.value = true;
      }
      messages.value = event.docs.map<Map<String, dynamic>>((e) => <String, dynamic>{...?(e.data() as Map?), 'id': e.id}).toList();
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

  Future<void> getMessages([bool reset = false]) async {
    if (reset) {
      lastDoc = null;
      hasMore.value = true;
    }

    if (!hasMore.value) return;

    try {
      Query query = FirebaseFirestore.instance.collection('messages').doc(uid).collection(type);
      if (userData['shop_filter'] != null) {
        query = query.where('orderFrom', isEqualTo: userData['shop_filter']);
      }
      final result = await query.orderBy('createdAt', descending: true).limit(limit).startAfterDocument(lastDoc!).get();

      final newDocs = result.docs;

      if (newDocs.isEmpty) {
        hasMore.value = false;
        return;
      }

      lastDoc = newDocs.last;

      final existingIds = (messages.value ?? []).map((m) => m['id']).toSet();

      final newMessages = newDocs
          .map((e) => <String, dynamic>{...?(e.data() as Map?), 'id': e.id})
          .where((m) => !existingIds.contains(m['id']))
          .toList();

      messages.value = [
        ...(messages.value ?? []),
        ...newMessages,
      ];
    } catch (error) {
      // AppSnackBar.error(error.toString());
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
    XFile? audio = selectedFile.value;
    selectedFile.value = null;

    isSending.value = true;

    if (audio != null && isAudioSelected.value) {
      content = '<audio>';
    } else if (audio != null) {
      content = '<image>';
    }

    try {
      String? downloadUrl;
      if (audio != null) {
        final path = audio.path;
        final response = await html.HttpRequest.request(path, responseType: 'arraybuffer');
        final data = response.response as ByteBuffer;
        final ref = FirebaseStorage.instance.ref().child('uploads/${path.split('/').last}');
        final uploadTask = await ref.putData(Uint8List.view(data));
        downloadUrl = await uploadTask.ref.getDownloadURL();
      }
      CollectionReference reference = FirebaseFirestore.instance.collection('messages').doc(uid).collection(type);
      final ref = reference.doc();
      await ref.set({
        'receiver': uid,
        'sender': 'admin',
        'content': content,
        'audioFile': downloadUrl,
        'createdAt': DateTime.now(),
        'orderFrom': userData['shop_filter'] ?? 'Marutti Mitra'
      });
      await PushNotificationsHelper.sendNotification(title: username, body: content.isNotEmpty ? content : isAudioSelected.value ? 'Audio File' : 'Image File', token: firebaseToken);
    } catch (error) {
      // AppSnackBar.error(error.toString());
    } finally {
      isSending.value = false;
    }
  }

  Future<void> toggleRecording() async {
    try {
      // final permission = await Permission.microphone.request();
      //
      // if (permission.isPermanentlyDenied) {
      //   AppSnackBar.error('Microphone permission permanently denied. Please enable it from app settings.');
      //   await openAppSettings();
      //   return;
      // }
      //
      // if (!permission.isGranted) {
      //   AppSnackBar.error('Please grant microphone permission to record audio.');
      //   return;
      // }
      recordingTimer?.cancel();
      if (waveController.isRecording) {
        await waveController.stopRecording();
        isRecording.value = false;
      } else {
        selectedFile.value = null;
        await waveController.startRecording();
        isRecording.value = true;
        // Automatically stop recording after 5 minutes
        recordingTimer = Timer(Duration(minutes: 5), () async {
          if (waveController.isRecording) {
            await waveController.stopRecording();
            isRecording.value = false;
          }
        });
      }
    } catch (error) {
      AppSnackBar.error('Something went wrong while starting recording: $error');
    }
  }

  Future<void> onRecordingStopped() async {
    final file = waveController.file;
    if (file == null) return;

    isAudioSelected.value = true;
    selectedFile.value = file;
  }

  Future<void> discardRecording() async {
    selectedFile.value = null;
  }

  Future<void> startPlayer(String url) async {
    try {
      await player.pause();
      await player.stop();
      isPlaying.value = false;
    } catch (_) {}
    currentPlayingAudio.value = url;
    try {
      await player.setUrl(url);

      await player.play();
      isPlaying.value = true;
    } catch (e) {
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
      final image = await imagePicker.pickFiles(type: FileType.image, withData: true);
      if (image != null && image.files.isNotEmpty) {
        final file = image.files.first.xFile;
        final sizeInMB = (await file.length()) / (1024 * 1024);
        if (sizeInMB > 10) {
          AppSnackBar.error('Image size exceeds limit of ${8} MB');
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