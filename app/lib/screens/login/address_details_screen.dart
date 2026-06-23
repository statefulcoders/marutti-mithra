import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:maruttimitra/configs/design/marutti_colors.dart';
import 'package:maruttimitra/screens/login/address_details_controller.dart';
import 'package:maruttimitra/widgets/app_root_container.dart';
import 'package:maruttimitra/widgets/custom_input_field.dart';

import '../../configs/local/app_configs.dart';
import '../../widgets/extra_field.dart';

class AddressDetailsScreen extends StatelessWidget {
  const AddressDetailsScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final AddressDetailsController controller = Get.find();

    return AppRootContainer(
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _createProgress(),
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
                SizedBox(height: 16.h),
                Center(
                  child: Obx(() => ElevatedButton(
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _createProgress() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _createStepCircle('1', false),
          Container(
            color: MaruttiColors.primaryColor,
            width: 12.w,
            height: 1.2,
          ),
          _createStepCircle('2', true)
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
