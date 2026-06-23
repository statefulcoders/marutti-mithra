import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:marutti_mitra_admin/comlate/widgets/comlate_root_container.dart';
import 'package:marutti_mitra_admin/screens/main/conversations/conversations_controller.dart';
import 'package:marutti_mitra_admin/screens/main/messages/messages_controller.dart';
import 'package:waveform_recorder/waveform_recorder.dart';

import '../../../utils/time_date_utils.dart';

class ConversationScreen extends StatelessWidget {
  final String label;
  final bool isDesktop;
  final Map<String, dynamic> userData;
  late final controller = Get.put(ConversationsController(userData: userData, type: label.toLowerCase()), tag: '$label${userData['uid']}${userData['shop_filter']}');

  ConversationScreen({super.key, required this.label, required this.isDesktop, required this.userData });

  @override
  Widget build(BuildContext context) {
    return ComlateRootContainer(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          forceMaterialTransparency: true,
          leading: isDesktop ? null : IconButton(onPressed: () {
            final controller = Get.find<MessagesController>(tag: label.toLowerCase());
            controller.openConversation.value = null;
          }, icon: Icon(Icons.arrow_back_ios_sharp)),
          title: Text(
            userData['username'] ?? 'Deleted User',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16.sp
            ),
          ),
        ),
          body: SafeArea(
            child: Obx(() =>  Column(
              children: [
                Expanded(
                  child: controller.messages.value == null ? Center(
                    child: CircularProgressIndicator(),
                  ) : controller.messages.value?.isEmpty == true ? Center(
                    child: Text(
                      'No Messages',
                      style: TextStyle(color: Colors.grey, fontSize: 16.sp, fontWeight: FontWeight.w500),
                    ),
                  ) : ListView.builder(
                    reverse: true,
                    controller: controller.scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    itemCount: controller.messages.value?.length ?? 0,
                    itemBuilder: (context, index) {
                      final msg = controller.messages.value![index];
                      return _createChatTile(msg);
                    },
                  ),
                ),
                _createMessageBox()
              ],
            )),
          )
      ),
    );
  }

  Widget _createChatTile(Map<String, dynamic> msg) {
    bool sentByMe = msg['sender'] == 'admin';
    String? audioFile = msg['audioFile'];
    String? content = msg['content'];
    String createdAt = DateFormat('dd MMMM yyyy, hh:mm a').format(msg['createdAt']?.toDate() ?? DateTime.now());

    return Align(
      alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft, // user message, keep as is
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12.r),
        ),
        constraints: BoxConstraints(maxWidth: 280.w),
        child: Column(
          crossAxisAlignment: sentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (audioFile != null && content == '<image>') _createPhoto(audioFile) else if (audioFile != null) _createAudioPlayerWidget(audioFile) else if (content != null) Text(
              content,
              style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 4.h),
            Text(
              createdAt,
              style: TextStyle(color: Colors.grey.shade300, fontSize: 12.sp, fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }

  Widget _createPhoto(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      placeholder: (context, url) => Container(
        padding: EdgeInsets.all(20.w),
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _createAudioPreviewWidget() {
    return Row(
      children: [
        Expanded(
          child: Text(
            controller.selectedAudioName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.delete_outline,
            size: 28.sp,
            color: Colors.red,
          ),
          onPressed: controller.discardRecording,
        )
      ],
    );
  }

  Widget _createAudioPlayerWidget(String audioUrl) {
    return Obx(() {
      final isLoading = controller.isPlayerLoading.value;
      final isPlaying = controller.isPlaying.value;
      final position = controller.position.value;
      final duration = controller.duration.value;

      final isCurrentActive = audioUrl == controller.currentPlayingAudio.value;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isCurrentActive && isLoading) Padding(
            padding: EdgeInsets.all(12.w),
            child: SizedBox(
              height: 20.sp,
              width: 20.sp,
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ) else IconButton(
            icon: Icon(
              isPlaying && isCurrentActive ? Icons.pause : Icons.play_arrow,
              size: 32.sp,
              color: Colors.white,
            ),
            onPressed: () {
              if (isCurrentActive && isPlaying) {
                controller.pausePlayer();
              } else if (isCurrentActive) {
                controller.resumePlayer();
              } else {
                controller.startPlayer(audioUrl);
              }
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Slider(
                  value: isCurrentActive ? position.inMilliseconds.toDouble().clamp(0.0, duration.inMilliseconds.toDouble()) : 0,
                  max: isCurrentActive ? duration.inMilliseconds.toDouble() : 1,
                  onChanged: (value) {
                    controller.seekPlayer(Duration(milliseconds: value.toInt()));
                  },
                  activeColor: Colors.white,
                  inactiveColor: Colors.grey.shade500,
                ),
                Text(
                  TimeDateUtils.formatDuration((isCurrentActive ? position : Duration.zero).inSeconds),
                  style: TextStyle(color: Colors.white, fontSize: 12.sp),
                )
              ],
            ),
          )
        ],
      );
    });
  }

  Widget _createMessageBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(top: BorderSide(color: Get.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Obx(() => controller.isRecording.value || controller.isSending.value ? SizedBox() : IconButton(
            icon: controller.isSending.value ? SizedBox(height: 20.sp, width: 20.sp, child: CircularProgressIndicator()) : Icon(Icons.photo, size: 25.sp, color: Colors.grey.shade600),
            onPressed: controller.chooseImage,
          )),
          // SizedBox(width: 5.w),
          if (controller.isRecording.value) Expanded(
            child: WaveformRecorder(
                height: 48,
                controller: controller.waveController,
                onRecordingStopped: controller.onRecordingStopped,
                waveColor: Colors.grey.shade600
            ),
          ) else if (controller.selectedFile.value != null) Expanded(
              child: _createAudioPreviewWidget()
          ) else Expanded(
            child: CustomInputField(
              hint: 'Type Message...',
              controller: controller.messageController,
              textInputAction: TextInputAction.send,
              textCapitalization: TextCapitalization.sentences
            ),
          ),
          Obx(() => IconButton(
            icon: controller.isSending.value ? SizedBox(height: 20.sp, width: 20.sp, child: CircularProgressIndicator()) : Icon(
              /*controller.canSend.value || controller.selectedFile.value != null ?*/ Icons.send /*: controller.isRecording.value ? Icons.stop : Icons.mic*/,
              size: 28.sp,
              color: Colors.grey.shade600,
            ),
            onPressed: /*controller.isSending.value ? null : controller.selectedFile.value != null || controller.canSend.value ?*/ controller.sendMessage /*: controller.toggleRecording*/,
          )),
        ],
      ),
    );
  }
}


class CustomInputField extends StatelessWidget {
  final IconData? icon;
  final Widget? prefix;
  final String hint;
  final TextEditingController? controller;
  final TextInputType inputType;
  final int? maxLength;
  final bool isEnabled;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;

  const CustomInputField({
    super.key,
    this.icon,
    this.prefix,
    required this.hint,
    this.controller,
    this.inputType = TextInputType.text,
    this.maxLength,
    this.textInputAction,
    this.isEnabled = true,
    this.textCapitalization = TextCapitalization.none
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLength: maxLength,
      controller: controller,
      keyboardType: inputType,
      textCapitalization: textCapitalization,
      keyboardAppearance: Brightness.light,
      textInputAction: textInputAction,
      enabled: isEnabled,
      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        counterText: "",
        prefixIcon: prefix ?? (icon == null ? null : Icon(icon, color: Colors.black54, size: 22.sp)),
        hintText: hint,
        hintStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500, color: Get.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
        labelStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: Colors.black12,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color:Get.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(15.r),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Get.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(15.r),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Get.isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300, width: 1.5),
          borderRadius: BorderRadius.circular(15.r),
        ),
      ),
    );
  }
}
