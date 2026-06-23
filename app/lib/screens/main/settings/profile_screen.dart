import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:maruttimitra/configs/design/marutti_colors.dart';
import 'package:maruttimitra/resources/marutti_logos.dart';
import 'package:maruttimitra/widgets/app_root_container.dart';
import 'package:maruttimitra/widgets/extra_field.dart';
import '../../../configs/local/app_configs.dart';
import '../../../widgets/custom_input_field.dart';
import 'profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find();
    
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('your_profile'.tr, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w600)),
        leading: IconButton(onPressed: Get.back, icon: Icon(Icons.arrow_back_ios, size: 20.sp)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Obx(() => controller.initializing.value ? Center(
          child: CircularProgressIndicator(),
        ) : SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 42.h),
                    padding: EdgeInsets.only(top: 55.h, left: 16.w, right: 16.w, bottom: 24.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 12.h),
                        CustomInputField(
                          icon: Icons.person,
                          hint: "first_name".tr,
                          controller: controller.firstNameCtrl,
                          textCapitalization: TextCapitalization.words,
                          inputType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: 12.h),
                        CustomInputField(
                          icon: Icons.person,
                          hint: "last_name".tr,
                          controller: controller.lastNameCtrl,
                          textCapitalization: TextCapitalization.words,
                          inputType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: 12.h),
                        CustomInputField(
                          icon: Icons.call,
                          hint: "phone_number".tr,
                          controller: controller.phoneCtrl,
                          inputType: TextInputType.phone,
                          isEnabled: false,
                        ),
                        SizedBox(height: 12.h),
                        CustomInputField(
                          icon: Icons.email,
                          hint: "email".tr,
                          controller: controller.emailCtrl,
                          inputType: TextInputType.emailAddress,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: 12.h),
                        GestureDetector(
                          onTap: () => controller.selectDate(context),
                          child: AbsorbPointer(
                            child: CustomInputField(
                              icon: Icons.calendar_today,
                              hint: "birthday".tr,
                              controller: controller.birthdayCtrl,
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Stack(
                        children: [
                          Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(500.r),
                              side: BorderSide(color: MaruttiColors.primaryColor, width: 1.5),
                            ),
                            elevation: 0,
                            clipBehavior: Clip.hardEdge,
                            child: Padding(
                              padding: EdgeInsets.all(4.w),
                              child: CircleAvatar(
                                  radius: 40.r,
                                  backgroundColor: Colors.white,
                                  child: Image.asset(
                                    MaruttiLogos.user,
                                    width: 60.w,
                                    height: 60.w,
                                  )
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                'address_details'.tr,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18.sp
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12.r),
                    color: Colors.white
                ),
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    SizedBox(height: 16.h),
                    CustomInputField(
                      hint: 'your_state'.tr,
                      controller: controller.stateController,
                      icon: Icons.place,
                      textCapitalization: TextCapitalization.words,
                      maxLength: AppConfig.nameLength,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 16.h),
                    CustomInputField(
                      hint: 'your_district'.tr,
                      controller: controller.districtController,
                      icon: Icons.location_city,
                      textCapitalization: TextCapitalization.words,
                      maxLength: AppConfig.nameLength,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 16.h),
                    CustomInputField(
                      hint: 'pincode'.tr,
                      controller: controller.pinCodeController,
                      icon: Icons.share_location_rounded,
                      maxLength: AppConfig.pinCodeLength,
                      inputType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 16.h),
                    CustomInputField(
                      hint: 'street_address'.tr,
                      controller: controller.streetAddressController,
                      icon: Icons.line_axis,
                      textCapitalization: TextCapitalization.words,
                      maxLength: AppConfig.streetAddressLength,
                      inputType: TextInputType.streetAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
          Obx(() => controller.extraFields.isNotEmpty ? Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: Text(
                  'other_details'.tr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 18.sp
                  ),
                ),
          ) : SizedBox()),
              Obx(() => controller.extraFields.isNotEmpty ? Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12.r),
                      color: Colors.white
                  ),
                  margin: EdgeInsets.only(top: 16.h),
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: controller.extraFields.map((element) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: ExtraField(
                            field: element,
                            valuesGallery: controller.extraFieldValues,
                          onSubmitted: controller.onExtraFieldSubmitted
                        )
                    )).toList()
                  )
              ) : SizedBox()),
              SizedBox(height: 20.h),
              Center(
                child: SizedBox(
                  width: 160.w,
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : controller.updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MaruttiColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 20.w),
                    ),
                    child: controller.isLoading.value
                        ? SizedBox(
                      height: 18.sp,
                      width: 18.sp,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : Text("update".tr, style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600)),
                  )),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        )),
      ),
    );
  }
}
