
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:marutti_mitra_admin/comlate/data/configs/app_config.dart';
import 'package:marutti_mitra_admin/comlate/dialogs/data_updater_dialog.dart';
import 'package:marutti_mitra_admin/helpers/firebase/firebase_users_helper.dart';
import 'package:marutti_mitra_admin/screens/main/users/users_controller.dart';

import '../../../comlate/utils/display/comlate_display_utils.dart';
import '../../../comlate/widgets/firebase_table/comlate_firebase_table.dart';

class UsersPage extends StatelessWidget {
  final String label;

  final bool deleteUser;
  final bool updateUser;
  final bool addPoints;
  final bool exportData;

  const UsersPage({super.key, required this.label, required this.deleteUser, required this.updateUser, required this.addPoints, required this.exportData});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UsersController(label: label));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (addPoints) _createPointAdder(context, controller),
          Obx(() => controller.extraFields.value == null ? Center(
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: CircularProgressIndicator(),
            ),
          ) : ComlateFirebaseTable(
            columns: controller.columns,
            dataSource: FirebaseUsersHelper.ref,
            onDataEdited: controller.onPointsChanged,
            identifier: label,
            customActionLabel: "Create New User",
            onAction: controller.createUser,
            sortBy: 'createdAt',
            enableDeletion: deleteUser,
            enableDetails: true,
            enableEditing: updateUser,
            enableExport: exportData,
            enableAction: true,
            onSaveOrder: controller.saveOrder,
            exportOrder: {
              'shopName': 1,
              'firstName': 2,
              'lastName': 3,
              'phone': 4,
              'email': 5,
              'address': 6,
              'district': 7,
              'state': 8,
              'pinCode': 9,
              'buyerCategory': 10,
              'maPoints': 11,
              'mwPoints': 12,
              'hpPoints': 13,
              'vcPoints': 14,
              'dateOfBirth': 15,
            },
            updateConfig: controller.getSortedFields(),
            onSelected: (data) => controller.selectUser({
              'uid': data.id,
              ...(data.data() as Map<String, dynamic>)
            }),
          )),
        ],
      ),
    );
  }

  Widget _createPointAdder(BuildContext context, UsersController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textStyle = TextStyle(
        fontSize: 13.sp,
    );

    final children = [
      _createUserSelector(context, controller),
      SizedBox(width: 6.w, height: 6.h),
      _createShopSelector(context, controller),
      SizedBox(width: 6.w, height: 6.h),
      _createProductSelector(context, controller),
      SizedBox(width: 6.w, height: 6.h),
      _createQuantityField(context, controller),
      SizedBox(width: 6.w, height: 6.h),
      ElevatedButton(
          onPressed: controller.providePoints,
          child: Text('Add Points', style: textStyle)
      )
    ];

    final isPhone = ComlateDisplayUtils.getDeviceType(context) == ComlateDisplayType.phone || ComlateDisplayUtils.getDeviceType(context) == ComlateDisplayType.tablet;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.transparent : Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.radius.r)
      ),
      padding: EdgeInsets.all(8.w),
      margin: EdgeInsets.symmetric(vertical: 12.h),
      child: isPhone ? Column(
        children: children,
      ) : Row(
        children: List.generate(children.length, (index) => [0, 2, 4, 6].contains(index) ? Expanded(flex: index != 6 ? 2 : 1, child: children[index]) : children[index]),
      ),
    );
  }

  Widget _createUserSelector(BuildContext context, UsersController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final hintColor = isDark ? Colors.grey[500] : Colors.grey[500];
    final borderColor = isDark ? Colors.grey[500]! : Colors.grey[400]!;
    final focusedBorderColor = isDark ? Colors.blue[300]! : Theme.of(context).primaryColor;
    final fillColor = isDark ? Colors.grey[800] : Colors.grey[50];
    final textStyle = TextStyle(
        fontSize: 13.sp,
        color: textColor
    );

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
              borderSide: BorderSide(
                color: borderColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConfig.radius.r),
              borderSide: BorderSide(
                color: borderColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConfig.radius.r),
              borderSide: BorderSide(
                color: focusedBorderColor,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.all(6.w),
          ),
        );
      },
      itemBuilder: (context, user) {
        final shopName = user['shopName']?.toString() ?? 'None';
        final district = user['district']?.toString()  ?? 'None';
        return _createSuggestionTile(shopName.isEmpty ? 'None' : shopName, district.isEmpty ? 'None' : district);
      },
      onSelected: controller.selectUser,
    );
  }

  Widget _createShopSelector(BuildContext context, UsersController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final hintColor = isDark ? Colors.grey[500] : Colors.grey[500];
    final borderColor = isDark ? Colors.grey[500]! : Colors.grey[400]!;
    final focusedBorderColor = isDark ? Colors.blue[300]! : Theme.of(context).primaryColor;
    final fillColor = isDark ? Colors.grey[800] : Colors.grey[50];
    final textStyle = TextStyle(
        fontSize: 13.sp,
        color: textColor
    );

    return Obx(() => DropdownButtonFormField(
      value: controller.selectedShop.value,
        items: controller.points.value.keys.map((e) => DropdownMenuItem(
          value: e,
          child: Text(e, style: textStyle),
        )).toList(),
        style: textStyle,
        dropdownColor: Get.isDarkMode ? Colors.grey.shade900 : Colors.white,
        onChanged: controller.selectShop,
      decoration: InputDecoration(
        hintText: 'Select Shop',
        hintStyle: textStyle.copyWith(color: hintColor),
        filled: false,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.radius.r),
          borderSide: BorderSide(
            color: borderColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.radius.r),
          borderSide: BorderSide(
            color: borderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.radius.r),
          borderSide: BorderSide(
            color: focusedBorderColor,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.all(6.w),
      ),
    ));
  }

  Widget _createProductSelector(BuildContext context, UsersController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final hintColor = isDark ? Colors.grey[500] : Colors.grey[500];
    final borderColor = isDark ? Colors.grey[500]! : Colors.grey[400]!;
    final focusedBorderColor = isDark ? Colors.blue[300]! : Theme.of(context).primaryColor;
    final fillColor = isDark ? Colors.grey[800] : Colors.grey[50];
    final textStyle = TextStyle(
        fontSize: 13.sp,
        color: textColor
    );

    return TypeAheadField<String>(
      suggestionsCallback: (search) => controller.findProduct(search),
      controller: controller.productSearchController,
      builder: (context, controller, focusNode) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: false,
          style: textStyle,
          decoration: InputDecoration(
            hintText: 'Search Product...',
            hintStyle: textStyle.copyWith(color: hintColor),
            filled: false,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConfig.radius.r),
              borderSide: BorderSide(
                color: borderColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConfig.radius.r),
              borderSide: BorderSide(
                color: borderColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConfig.radius.r),
              borderSide: BorderSide(
                color: focusedBorderColor,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.all(6.w),
          ),
        );
      },
      itemBuilder: (context, product) {
        String points = controller.products.value.where((p) => p['name'] == product && p['shop'] == controller.selectedShop.value).firstOrNull?['points']?.toString() ?? '0';
        return _createSuggestionTile(product, 'Points: $points');
      },
      onSelected: controller.selectProduct,
    );
  }


  Widget _createQuantityField(BuildContext context, UsersController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final hintColor = isDark ? Colors.grey[500] : Colors.grey[500];
    final borderColor = isDark ? Colors.grey[500]! : Colors.grey[400]!;
    final focusedBorderColor = isDark ? Colors.blue[300]! : Theme.of(context).primaryColor;
    final fillColor = isDark ? Colors.grey[800] : Colors.grey[50];
    final textStyle = TextStyle(
        fontSize: 13.sp,
        color: textColor
    );

    return TextField(
      controller: controller.quantityController,
      autofocus: false,
      keyboardType: TextInputType.number,
      maxLength: 5,
      style: textStyle,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
      ],
      decoration: InputDecoration(
        hintText: 'Quantity',
        counterText: '',
        hintStyle: textStyle.copyWith(color: hintColor),
        filled: false,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.radius.r),
          borderSide: BorderSide(
            color: borderColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.radius.r),
          borderSide: BorderSide(
            color: borderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.radius.r),
          borderSide: BorderSide(
            color: focusedBorderColor,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.all(6.w),
      ),
    );
  }

  Widget _createSuggestionTile(String title, String subtitle) {
    final textColor = Get.isDarkMode ? Colors.white : Colors.black;
    final textStyle = TextStyle(
        fontSize: 13.sp,
        color: textColor
    );

    return ListTile(
      tileColor: Get.isDarkMode ? Colors.grey.shade900 : Colors.white,
      title: Text(title, style: textStyle),
      subtitle: Text(subtitle, style: textStyle),
    );
  }
}
