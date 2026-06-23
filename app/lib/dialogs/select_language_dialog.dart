import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:maruttimitra/configs/design/marutti_colors.dart';
import 'package:maruttimitra/models/local/app_language_model.dart';

import '../utils/settings/marutti_settings_memory.dart';

class SelectLanguageDialog extends StatelessWidget {
  const SelectLanguageDialog({super.key});

  static Future<void> show(BuildContext context) async {
    return Get.bottomSheet(
      SelectLanguageDialog(),
      elevation: 0,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // barrierColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12.r),
                  color: Colors.white
              ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 12.h),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Text(
                      'select_your_language'.tr,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 20.sp
                      )
                    ),
                  ),
                  ...MaruttiSettingsMemory.allLanguages.map(_createLanguageTile)
                ],
              ),
            )
          ),
        ],
      ),
    );
  }

  Widget _createLanguageTile(AppLanguageModel language) {
    bool isSelected = language.code == MaruttiSettingsMemory.currentLanguage.code;
    return Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.r),
            side: BorderSide(color: MaruttiColors.primaryColor, width: 1.w)
        ),
        clipBehavior: Clip.hardEdge,
        color: isSelected ? MaruttiColors.primaryColor : Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: 12.w, horizontal: 12.w),
        child: InkWell(
          onTap: () {
            MaruttiSettingsMemory.setLanguage(language);
            Get.back();
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    language.localName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 18.sp
                    ),
                  ),
                ),
                IgnorePointer(
                  ignoring: true,
                  child: Radio(
                    activeColor: isSelected ? Colors.white : MaruttiColors.primaryColor,
                      fillColor: WidgetStatePropertyAll(isSelected ? Colors.white : MaruttiColors.primaryColor),
                      value: isSelected,
                      groupValue: true,
                      onChanged: (v) {}
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}
