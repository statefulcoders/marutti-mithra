import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:marutti_mitra_admin/comlate/data/configs/app_config.dart';
import 'package:marutti_mitra_admin/comlate/dialogs/data_updater_dialog.dart';
import 'package:marutti_mitra_admin/comlate/utils/display/comlate_display_utils.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_reward_users_helper.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_rewards_helper.dart';
import 'package:marutti_mitra_admin/screens/main/coupon_distribution/reward_users_controller.dart';

import '../../../comlate/widgets/firebase_table/comlate_firebase_table.dart';

class RewardUsersPage extends StatelessWidget {
  final String label;
  final bool exportData;

  const RewardUsersPage({super.key, required this.label, required this.exportData});

  @override
  Widget build(BuildContext context) {
    // Put the RewardUsersController
    final controller = Get.put(RewardUsersController(label: label));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Distribution Panel
            _createRewardDistributor(context, controller),

            ComlateFirebaseTable(
              sortBy: 'createdAt',
              columns: controller.columns,
              dataSource: FirebaseRewardUsersHelper.ref,
              identifier: label,
              enableEditing: true,
              enableDeletion: true,
              enableDetails: true,
              customActionLabel: 'Redeem All',
              onAction: controller.redeemAll,
              enableExport: exportData,
              enableAction: true,
              updateConfig: [
                DataUpdateFieldInfo(key: 'firstName', expectedType: 'text', editable: false, required: false),
                DataUpdateFieldInfo(key: 'lastName', expectedType: 'text', editable: false, required: false),
                DataUpdateFieldInfo(key: 'phone', expectedType: 'text', editable: false),
                DataUpdateFieldInfo(key: 'district', expectedType: 'text', editable: false),
                DataUpdateFieldInfo(key: 'shopName', expectedType: 'text', editable: false),
                DataUpdateFieldInfo(key: 'rewardName', expectedType: 'text', editable: false),
                DataUpdateFieldInfo(key: 'couponType', expectedType: 'text', editable: false),
                DataUpdateFieldInfo(key: 'distributedAt', expectedType: 'date', editable: false),
                DataUpdateFieldInfo(key: 'expiresAt', expectedType: 'date', editable: false),
                DataUpdateFieldInfo(key: 'couponType', expectedType: 'text', editable: false),
                DataUpdateFieldInfo(key: 'status', expectedType: 'dropdown', options: ['scratched', 'assigned', 'redeemed', 'expired'], required: true),
              ]
            ),
          ],
        ),
      ),
    );
  }

  Widget _createRewardDistributor(BuildContext context, RewardUsersController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textStyle = TextStyle(fontSize: 13.sp);

    final children = [
      _createUserSelector(context, controller),
      SizedBox(width: 6.w, height: 6.h),
      _createRewardSelector(context, controller),
      SizedBox(width: 6.w, height: 6.h),
      _createQuantityField(context, controller),
      SizedBox(width: 6.w, height: 6.h),
      ElevatedButton(
        onPressed: controller.distributeReward,
        child: Text('Add Reward', style: textStyle),
      )
    ];

    final isPhone = ComlateDisplayUtils.getDeviceType(context) == ComlateDisplayType.phone ||
        ComlateDisplayUtils.getDeviceType(context) == ComlateDisplayType.tablet;

    return Container(
      decoration: BoxDecoration(
          color: isDark ? Colors.transparent : Colors.white,
          borderRadius: BorderRadius.circular(AppConfig.radius.r)),
      padding: EdgeInsets.all(8.w),
      margin: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      child: isPhone
          ? Column(children: children)
          : Row(
        children: List.generate(
            children.length,
                (index) => [0, 2, 4].contains(index)
                ? Expanded(flex: 2, child: children[index])
                : children[index]),
      ),
    );
  }

  Widget _createUserSelector(BuildContext context, RewardUsersController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final hintColor = isDark ? Colors.grey[500] : Colors.grey[500];
    final borderColor = isDark ? Colors.grey[500]! : Colors.grey[400]!;
    final focusedBorderColor = isDark ? Colors.blue[300]! : Theme.of(context).primaryColor;
    final fillColor = isDark ? Colors.grey[800] : Colors.grey[50];
    final textStyle = TextStyle(fontSize: 13.sp, color: textColor);

    return TypeAheadField<Map<String, dynamic>>(
      suggestionsCallback: (search) => controller.findUser(search),
      controller: controller.userSearchController,
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: false,
          style: textStyle,
          decoration: InputDecoration(
            hintText: 'Search User...',
            hintStyle: textStyle.copyWith(color: hintColor),
            filled: false,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConfig.radius.r),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConfig.radius.r),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConfig.radius.r),
              borderSide: BorderSide(color: focusedBorderColor, width: 2),
            ),
            contentPadding: EdgeInsets.all(6.w),
          ),
        );
      },
      itemBuilder: (context, user) {
        final shopName = user['shopName']?.toString() ?? 'None';
        final district = user['district']?.toString() ?? 'None';
        return _createSuggestionTile(
            shopName.isEmpty ? 'None' : shopName, district.isEmpty ? 'None' : district);
      },
      onSelected: controller.selectUser,
    );
  }

  Widget _createRewardSelector(BuildContext context, RewardUsersController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final hintColor = isDark ? Colors.grey[500] : Colors.grey[500];
    final borderColor = isDark ? Colors.grey[500]! : Colors.grey[400]!;
    final focusedBorderColor = isDark ? Colors.blue[300]! : Theme.of(context).primaryColor;
    final fillColor = isDark ? Colors.grey[800] : Colors.grey[50];
    final textStyle = TextStyle(fontSize: 13.sp, color: textColor);

    return TypeAheadField<Map<String, dynamic>>(
      suggestionsCallback: (search) => controller.findReward(search),
      controller: controller.rewardSearchController,
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: false,
          style: textStyle,
          decoration: InputDecoration(
            hintText: 'Search Reward...',
            hintStyle: textStyle.copyWith(color: hintColor),
            filled: false,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConfig.radius.r),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConfig.radius.r),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConfig.radius.r),
              borderSide: BorderSide(color: focusedBorderColor, width: 2),
            ),
            contentPadding: EdgeInsets.all(6.w),
          ),
        );
      },
      itemBuilder: (context, reward) {
        final name = reward['name']?.toString() ?? 'Unknown';

        // --- Subtitle Logic ---
        final stats = controller.getRewardStats(reward);
        final distributed = stats['distributed'];
        final total = stats['total'];

        return _createSuggestionTile(name, 'Distributed: $distributed / $total');
      },
      onSelected: controller.selectReward,
    );
  }

  Widget _createQuantityField(BuildContext context, RewardUsersController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final hintColor = isDark ? Colors.grey[500] : Colors.grey[500];
    final borderColor = isDark ? Colors.grey[500]! : Colors.grey[400]!;
    final focusedBorderColor = isDark ? Colors.blue[300]! : Theme.of(context).primaryColor;
    final fillColor = isDark ? Colors.grey[800] : Colors.grey[50];
    final textStyle = TextStyle(fontSize: 13.sp, color: textColor);

    return TextField(
      controller: controller.quantityController,
      autofocus: false,
      keyboardType: TextInputType.number,
      maxLength: 5,
      style: textStyle,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        hintText: 'Quantity',
        counterText: '',
        hintStyle: textStyle.copyWith(color: hintColor),
        filled: false,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.radius.r),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.radius.r),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.radius.r),
          borderSide: BorderSide(color: focusedBorderColor, width: 2),
        ),
        contentPadding: EdgeInsets.all(6.w),
      ),
    );
  }

  Widget _createSuggestionTile(String title, String subtitle) {
    final textColor = Get.isDarkMode ? Colors.white : Colors.black;
    final textStyle = TextStyle(fontSize: 13.sp, color: textColor);

    return ListTile(
      tileColor: Get.isDarkMode ? Colors.grey.shade900 : Colors.white,
      title: Text(title, style: textStyle),
      subtitle: Text(subtitle, style: textStyle),
    );
  }
}