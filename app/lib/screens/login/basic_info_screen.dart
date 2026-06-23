import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:maruttimitra/configs/design/marutti_colors.dart';
import 'package:maruttimitra/configs/local/app_configs.dart';
import 'package:maruttimitra/screens/login/basic_info_controller.dart';
import 'package:maruttimitra/widgets/app_root_container.dart';
import 'package:maruttimitra/widgets/custom_input_field.dart';

class BasicInfoScreen extends StatelessWidget {
  const BasicInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BasicInfoController controller = Get.find();

    return AppRootContainer(
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _createProgress(1),
                Text(
                  'basic_information'.tr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600
                  )
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
                        hint: 'your_first_name'.tr,
                        controller: controller.firstNameController,
                        icon: Icons.person,
                        textCapitalization: TextCapitalization.words,
                        maxLength: AppConfig.nameLength,
                        inputType: TextInputType.name,
                          textInputAction: TextInputAction.next
                      ),
                      SizedBox(height: 16.h),
                      CustomInputField(
                        hint: 'your_last_name'.tr,
                        controller: controller.lastNameController,
                        icon: Icons.person,
                        textCapitalization: TextCapitalization.words,
                        inputType: TextInputType.name,
                        maxLength: AppConfig.nameLength,
                          textInputAction: TextInputAction.next
                      ),
                      SizedBox(height: 16.h),
                      CustomInputField(
                        hint: 'email_id'.tr,
                        controller: controller.emailController,
                        icon: Icons.email,
                        maxLength: AppConfig.emailLength,
                        inputType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next
                      ),
                      SizedBox(height: 16.h),
                      GestureDetector(
                        onTap: () => controller.selectDate(context),
                        child: AbsorbPointer(
                          child: CustomInputField(
                            icon: Icons.calendar_today,
                            hint: "birthday".tr,
                            controller: controller.dobController,
                          ),
                        ),
                      ),
                      SizedBox(height: 26.h),
                      Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value ? null : controller.submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MaruttiColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 26.w),
                        ),
                        child: controller.isLoading.value
                            ? SizedBox(
                          height: 18.sp,
                          width: 18.sp,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                            : Text('submit'.tr, style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600)),
                      )),
                      SizedBox(height: 16.h),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _createProgress(int step) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _createStepCircle('1', true),
          Container(
            color: MaruttiColors.primaryColor,
            width: 12.w,
            height: 1.2,
          ),
          _createStepCircle('2', false)
        ],
      ),
    );
  }

  Widget _createStepCircle(String text, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: MaruttiColors.primaryColor, width: 1.2),
        borderRadius: BorderRadius.circular(1000.r),
        color: MaruttiColors.primaryColor.withAlpha(isSelected ? 150 : 20)
      ),
      child: SizedBox(
        height: 24.w,
        width: 24.w,
        child: Center(child: Text(text)),
      ),
    );
  }
}
