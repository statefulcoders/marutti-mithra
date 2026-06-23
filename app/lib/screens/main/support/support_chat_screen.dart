import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maruttimitra/configs/design/marutti_colors.dart';
import 'package:maruttimitra/models/remote/message_model.dart';
import 'package:maruttimitra/screens/main/support/support_chat_controller.dart';
import 'package:maruttimitra/utils/message_table_helper.dart';
import 'package:maruttimitra/utils/time_date_utils.dart';
import 'package:maruttimitra/widgets/app_root_container.dart';
import 'package:maruttimitra/widgets/custom_input_field.dart';
import 'package:waveform_recorder/waveform_recorder.dart';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> with WidgetsBindingObserver {
  final SupportChatController controller = Get.put(SupportChatController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => controller.askForFirm());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (controller.isPlaying.value) {
        controller.pausePlayer();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppRootContainer(
      child: Scaffold(
          backgroundColor: Colors.grey.shade100,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            title: Text(controller.title.tr),
            leading: IconButton(onPressed: Get.back, icon: Icon(Icons.arrow_back_ios, size: 20.sp)),
          ),
          body: SafeArea(
            child: Obx(() =>  Column(
              children: [
                Expanded(
                  child: controller.messages.value == null ? Center(
                    child: CircularProgressIndicator(),
                  ) : controller.messages.value?.isEmpty == true ? Center(
                    child: Text(
                      'no_messages'.tr,
                      style: TextStyle(color: Colors.grey, fontSize: 16.sp, fontWeight: FontWeight.w500),
                    ),
                  )
                      : ListView.builder(
                    reverse: true,
                    controller: controller.scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    itemCount: controller.messages.value?.length ?? 0,
                    itemBuilder: (context, index) {
                      final msg = controller.messages.value![index];
                      final tile = _createChatTile(msg);

                      String? shoppingAt;

                      if (controller.category == MessageTableHelper.categoryOrder) {
                        if (index == 0 && msg.orderFrom != null && msg.orderFrom?.isNotEmpty == true) {
                          shoppingAt = msg.orderFrom;
                        } else if (index > 0) {
                          final prevMsg = controller.messages.value![index - 1];
                          if (prevMsg.orderFrom != null && prevMsg.orderFrom?.isNotEmpty == true && msg.orderFrom != null && msg.orderFrom?.isNotEmpty == true && prevMsg.orderFrom != msg.orderFrom) {
                            shoppingAt = msg.orderFrom;
                          }
                        }
                      }

                      if (shoppingAt == null) {
                        return tile;
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text.rich(
                                TextSpan(
                                  text: 'Ordering from ',
                                  style: TextStyle(
                                    color: Colors.black38,
                                    fontSize: 14.sp
                                  ),
                                  children: [
                                    TextSpan(
                                      text: shoppingAt,
                                      style: TextStyle(
                                        color: MaruttiColors.primaryColor
                                      )
                                    )
                                  ]
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            tile
                          ],
                        );
                      }
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

  Widget _createChatTile(MessageModel msg) {
    bool sentByMe = msg.sender == MessageTableHelper.senderYou;
    return Align(
      alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft, // user message, keep as is
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade700,
          borderRadius: BorderRadius.circular(12.r),
        ),
        constraints: BoxConstraints(maxWidth: 280.w),
        child: Column(
          crossAxisAlignment: sentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (msg.audioFile != null && msg.content == '<image>') _createPhoto(msg.audioFile!) else if (msg.audioFile != null) _createAudioPlayerWidget(msg.audioFile!) else if (msg.content != null) Text(
              msg.content ?? 'Empty Message',
              style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500),
            ),
              SizedBox(height: 4.h),
            Text(
              DateFormat('dd MMMM yyyy, hh:mm a').format(msg.createdAt),
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
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
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
              hint: 'send_message_hint'.tr,
              controller: controller.messageController,
              textInputAction: TextInputAction.send,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          Obx(() => IconButton(
            icon: controller.isSending.value ? SizedBox(height: 20.sp, width: 20.sp, child: CircularProgressIndicator()) : Icon(
              controller.canSend.value || controller.selectedFile.value != null ? Icons.send : controller.isRecording.value ? Icons.stop : Icons.mic,
              size: 28.sp,
              color: Colors.grey.shade600,
            ),
            onPressed: controller.isSending.value ? null : controller.selectedFile.value != null || controller.canSend.value ? controller.sendMessage : controller.toggleRecording,
          )),
        ],
      ),
    );
  }
}
