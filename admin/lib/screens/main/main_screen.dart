import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:marutti_mitra_admin/comlate/data/configs/app_config.dart';
import 'package:marutti_mitra_admin/comlate/data/resources/comlate_logos.dart';
import 'package:marutti_mitra_admin/comlate/widgets/comlate_root_container.dart';
import 'package:marutti_mitra_admin/comlate/widgets/responsive_navigation_rail.dart';

import 'main_controller.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainController());

    return ComlateRootContainer(
      child: Container(
        color: Colors.white,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Row(
            children: [
              _buildRailNavigation(controller),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                   Expanded(
                     child: NestedScrollView(
                       controller: controller.scrollController,
                         headerSliverBuilder: (context, innerBoxIsScrolled) => [
                           SliverPadding(
                               padding: EdgeInsets.symmetric(vertical: 25.h),
                             sliver: SliverAppBar(
                               pinned: false,
                               floating: false,
                               title: Obx(() => Text(
                                   controller.navigationItems.value[controller.selectedRailIndex.value].title
                               )),
                               centerTitle: false,
                               forceMaterialTransparency: true,
                               automaticallyImplyLeading: false,
                               actions: [
                                 IconButton(
                                   onPressed: controller.goToSettings,
                                   icon: ClipOval(
                                     child: Image.asset(
                                       ComlateLogos.profile,
                                       width: 40.w,
                                       height: 40.w,
                                     ),
                                   ),
                                 ),
                               ]
                             )
                           )
                         ],
                         body: pageHolder(
                           child: Obx(() => controller.pages.value[controller.selectedRailIndex.value])
                         )
                     ),
                   )
                  ],
                ),
              ),
              SizedBox(width: 20.w)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRailNavigation(MainController controller) {
    return Obx(() => ResponsiveNavigationRail(
      items: controller.navigationItems.value,
      enableLeading: true,
      enableTrailing: true,
      selectedIndex: controller.selectedRailIndex.value,
      onTrailingPressed: controller.logout,
      onDestinationSelected: controller.toggleRailIndex,
    ));
  }

  Widget pageHolder({ required Widget child }) {
    return child;
  }
}
