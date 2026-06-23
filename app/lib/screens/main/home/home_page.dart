import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maruttimitra/configs/design/marutti_colors.dart';
import 'package:maruttimitra/configs/local/constants.dart';
import 'package:maruttimitra/models/remote/catalogue_model.dart';
import 'package:maruttimitra/resources/marutti_icons.dart';
import 'package:maruttimitra/resources/marutti_logos.dart';
import 'package:maruttimitra/routes/marutti_routes.dart';
import 'package:maruttimitra/utils/settings/marutti_settings_memory.dart';
import 'package:maruttimitra/utils/user_table_helper.dart';
import 'package:maruttimitra/widgets/video_card.dart';
import 'package:shimmer/shimmer.dart';
import '../../../dialogs/select_language_dialog.dart';
import 'home_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();

    return Obx(() => Scaffold(
      backgroundColor: Colors.white,
      appBar: _createAppBar(context),
      body: UserTableHelper.user.value == null ? Center(child: CircularProgressIndicator())
          : SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.reloadOtherData,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTotalPointsSection(controller),
                SizedBox(height: 24.h),
                if (controller.videos.value?.isEmpty == false) ...[
                  Text(
                    'videos'.tr,
                    style: TextStyle(
                      fontSize: 20.sp, // Slightly larger for emphasis
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    height: Get.width * 0.36,
                    child: controller.videos.value == null ? wrapInShimmer(
                      child: Container(
                        color: Colors.grey.shade100,
                        child: Center(
                            child: CircularProgressIndicator()
                        ),
                      ),
                    ) : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.videos.value?.length ?? 0,
                      itemBuilder: (context, index) => VideoCard(url: controller.videos.value![index]),
                    ),
                  )
                ],
                SizedBox(height: 24.h),
                Text(
                  'pdf_catalogues'.tr,
                  style: TextStyle(
                    fontSize: 20.sp, // Slightly larger for emphasis
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16.h),
                controller.catalogues.value == null ? wrapInShimmer(
                  child: Container(
                    height: Get.width * 0.36,
                    color: Colors.grey.shade100,
                    child: Center(
                        child: CircularProgressIndicator()
                    ),
                  )
                ) : controller.catalogues.value?.isEmpty == true ? _buildEmptyCatalogueState(controller)
                    : Column(children: controller.catalogues.value!.map((c) => _buildCatalogue(c)).toList()),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  AppBar _createAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      leading: Padding(
        padding: EdgeInsets.all(8),
        child: Image.asset(
          MaruttiLogos.logoWithoutName,
        ),
      ),
      actions: [
        Image.asset(
          MaruttiIcons.translate,
          height: 30.w,
          width: 30.w,
        ),
        Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: GestureDetector(
            onTap: () => SelectLanguageDialog.show(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(MaruttiSettingsMemory.currentLanguage.localName, style: Theme.of(context).textTheme.bodyMedium),
                Padding(
                  padding: EdgeInsets.only(left: 4.w),
                  child: Image.asset(
                    MaruttiIcons.arrowDown,
                    height: 15.w,
                    width: 15.w,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 8.w),
        IconButton(
            onPressed: () => Get.toNamed(MaruttiRoutes.notifications),
            icon: Obx(() => Badge(
              backgroundColor: UserTableHelper.user.value?.unread == true ? Colors.red : Colors.transparent,
              child: Image.asset(
                MaruttiIcons.bell,
                height: 26.w,
                width: 26.w,
              ),
            ))
        ),
      ],
    );
  }

  Widget _buildTotalPointsSection(HomeController controller) {
    return Obx(() => Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        gradient: LinearGradient(
          colors: [
            MaruttiColors.primaryColor,
            MaruttiColors.primaryColor.withAlpha(150)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 12.r,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, size: 18.sp, color: Colors.white),
              SizedBox(width: 4.w),
              Text(
                'total_points'.tr,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            controller.formattedTotalPoints,
            style: TextStyle(
              fontSize: 48.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white
            ),
          ),
          TextButton.icon(
            onPressed: () {
              controller.showBreakdown.value = !controller.showBreakdown.value;
            },
            icon: Icon(
              controller.showBreakdown.value ? Icons.expand_less : Icons.expand_more,
              color: Colors.white
            ),
            label: Text(
              controller.showBreakdown.value ? 'hide_breakdown'.tr : 'show_breakdown'.tr,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ),
          if (controller.showBreakdown.value) ...[
            SizedBox(height: 8.h),
            _buildPointsDetailCard(controller),
          ],
        ],
      ),
    ));
  }

  Widget _buildPointsDetailCard(HomeController controller) {
    return Obx(() => Column(
      children: [
        ...{
        'MA Points': UserTableHelper.user.value?.maPoints ?? 0,
        'MW Points': UserTableHelper.user.value?.mwPoints ?? 0,
        'HP Points': UserTableHelper.user.value?.hpPoints ?? 0,
        'VC Points': UserTableHelper.user.value?.vcPoints ?? 0,
        }.entries.map((entry) {
          final icon = Icons.stars;
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 6.h),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 6.r,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: MaruttiColors.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(10.w),
                    child: Icon(icon, color: MaruttiColors.primaryColor, size: 22.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      entry.key.tr,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Text(
                    NumberFormat.decimalPattern().format(entry.value),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.blue.shade600,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'mg_points_total'.tr,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                controller.formattedTotalPoints,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }

  Widget _buildCatalogue(CatalogueModel model) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: GestureDetector(
        onTap: () {
          Get.toNamed(MaruttiRoutes.pdfViewer, parameters: {
            Constants.keyUrl: model.url
          });
        }, // Add your tap logic here
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            title: Text(
              model.name,
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.black,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            subtitle: Text(
              'tap_to_view_details'.tr,
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.black54,
              ),
            ),
            leading: Image.asset(
              MaruttiIcons.pdf,
              width: 28.w,
              height: 28.w,
              color: Colors.black
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16.w,
              color: Colors.black
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCatalogueState(HomeController controller) {
    return Container(
      color: Colors.grey.shade100,
      padding: EdgeInsets.symmetric(vertical: 26.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            duration: Duration(milliseconds: 300),
            scale: 1.0,
            child: Icon(
              Icons.insert_drive_file_outlined,
              size: 60.w,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'no_catalogues'.tr,
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'check_back_later'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget wrapInShimmer({ bool shimmer = true, required Widget child }) {
    if (shimmer) {
      return Shimmer.fromColors(baseColor: Colors.grey.shade100, highlightColor: Colors.white, child: child);
    }
    return child;
  }
}