import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:maruttimitra/utils/intent_utils.dart';
import 'support_controller.dart';
import 'package:maruttimitra/configs/design/marutti_colors.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SupportController controller = Get.find();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text('support'.tr, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w600)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("send_message".tr, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12.r),
                    color: Colors.white
                ),
                padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 16.h),
                child: Column(
                  children: [
                    OutlinedButton.icon(
                      onPressed: controller.placeAnOrder,
                      icon: Icon(Icons.message, color: Colors.black54, size: 22.sp),
                      style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1.2
                          )
                      ),
                      label: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("place_order".tr, style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500, color: Colors.black)),
                          Icon(Icons.arrow_forward, color: Colors.black,),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    OutlinedButton.icon(
                      onPressed: controller.feedbackOrComplaint,
                      icon: Icon(Icons.feedback, color: Colors.black54, size: 22.sp),
                      style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1.2
                          )
                      ),
                      label: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("complaint_or_feedback".tr, style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500, color: Colors.black)),
                          Icon(Icons.arrow_forward, color: Colors.black,),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Text("contact_us".tr, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12.r),
                    color: Colors.white
                ),
                padding: EdgeInsets.all(12.w),
                child: Column(
                  children: [
                    _buildContactTile(
                        label: 'email'.tr,
                        icon: Icons.email,
                        text: controller.email.value,
                      onPressed: () => IntentUtils.launchEmail(controller.email.value)
                    ),
                    Divider(color: Colors.grey.shade300, thickness: 1),
                    ...controller.contacts.entries.map((e) => [
                      _buildContactTile(
                          label: e.key.replaceAll('_', ' '),
                          icon: Icons.phone,
                          text: e.value,
                          onPressed: () => IntentUtils.launchCall(e.value)
                      ),
                      Divider(color: Colors.grey.shade300, thickness: 1),
                    ]).expand((element) => element),
                    _buildContactTile(
                        label: 'address'.tr,
                        icon: Icons.location_on,
                        text: controller.location.value,
                    ),
                    Divider(color: Colors.grey.shade300, thickness: 1),
                    _buildContactTile(
                        label: 'contact_time'.tr,
                        icon: Icons.access_time,
                        text: controller.hours.value,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Text("faq".tr, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12.r),
                    color: Colors.white
                ),
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...controller.faqs.map((faq) => Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      decoration: BoxDecoration(
                        color: MaruttiColors.primaryColor.withAlpha(14),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.symmetric(horizontal: 12.w),
                        title: Text(faq["question"]!.tr, style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500)),
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                            child: Text(faq["answer"]!.tr, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500)),
                          )
                        ],
                      ),
                    ))
                  ],
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  Widget _buildContactTile({ required String label, required IconData icon, required String text, VoidCallback? onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: EdgeInsets.all(10.0.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Icon(icon, color: Colors.black54, size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(label, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500, color: Colors.grey.shade500)),
                Text(text, style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w500)),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
