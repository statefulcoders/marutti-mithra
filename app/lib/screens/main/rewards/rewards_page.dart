import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:maruttimitra/configs/design/marutti_colors.dart';
import 'package:maruttimitra/models/remote/reward_model.dart';
import 'package:maruttimitra/screens/main/rewards/rewards_controller.dart';
import 'package:maruttimitra/widgets/app_root_container.dart';
import 'package:scratcher/scratcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RewardsController>();

    return AppRootContainer(
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: Text('rewards'.tr, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w600)),
        ),
        body: Obx(() {
          if (controller.rewards.value == null) {
             return const Center(child: CircularProgressIndicator());
          }
          if (controller.rewards.value!.isEmpty) {
             return Center(child: Text("no_rewards_yet".tr));
          }
          return RefreshIndicator(
            onRefresh: controller.fetchRewards,
            child: GridView.builder(
              padding: EdgeInsets.all(16.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: 0.8,
              ),
              itemCount: controller.rewards.value!.length,
              itemBuilder: (context, index) {
                return _buildRewardCard(context, controller.rewards.value![index], controller);
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRewardCard(BuildContext context, RewardModel reward, RewardsController controller) {
    final isScratched = reward.status == 'scratched' || reward.status == 'redeemed';
    final isExpired = reward.status == 'expired'; 
    
    // Calculate expiry days if needed
    String daysLeft = "";
    if (!isScratched && !isExpired) {
       final now = DateTime.now();
       final expiry = reward.expiresAt.toDate();
       final diff = expiry.difference(now).inDays;
       daysLeft = diff > 0 ? "days_left".trParams({'days': diff.toString()}) : "expiring_soon".tr;
    }

    return GestureDetector(
      onTap: () {
        if (isExpired) return;
        if (isScratched) {
          _showRewardDetailsDialog(context, reward);
        } else {
          _showScratchDialog(context, reward, controller);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: isScratched 
            ? _buildResultContent(reward)
            : isExpired 
                ? _buildExpiredContent()
                : _buildLockedContent(daysLeft),
      ),
    );
  }

  Widget _buildLockedContent(String daysLeft) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.blue.shade500, // Blue base
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade400,
                Colors.blue.shade600,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events_outlined, color: Colors.white.withOpacity(0.5), size: 48.sp),
                SizedBox(height: 8.h),
                Text(
                  "tap_to_scratch".tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Decorative background icons (optional subtleness)
        Positioned(
          top: -10, left: -10,
          child: Icon(Icons.card_giftcard, size: 80.sp, color: Colors.white.withOpacity(0.1)),
        ),
        Positioned(
          bottom: -10, right: -10,
          child: Icon(Icons.store, size: 80.sp, color: Colors.white.withOpacity(0.1)),
        ),
        // Days Left Pill
        if (daysLeft.isNotEmpty)
          Positioned(
            top: 8.h,
            right: 8.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                daysLeft,
                style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildResultContent(RewardModel reward) {
    return Column(
      children: [
        // Image Section (Top 65%)
        Expanded(
          flex: 65,
          child: Container(
            width: double.infinity,
            color: Colors.white,
            padding: EdgeInsets.all(8.w),
            child: (reward.image != null && reward.image!.isNotEmpty)
                ? CachedNetworkImage(
                    imageUrl: reward.image!,
                    fit: BoxFit.contain, // Contain to show full product
                    placeholder: (context, url) => Center(child: Icon(Icons.emoji_events, color: Colors.amber, size: 40.sp)),
                    errorWidget: (context, url, error) => Center(child: Icon(Icons.emoji_events, color: Colors.amber, size: 40.sp)),
                  )
                : Center(child: Icon(Icons.emoji_events, color: Colors.amber, size: 50.sp)),
          ),
        ),
        // Details Section (Bottom 35%)
        Expanded(
          flex: 35,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E), // Dark background
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  reward.rewardName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                if (reward.description != null && reward.description!.isNotEmpty)
                  Text(
                    reward.description!,
                    style: TextStyle(
                      fontSize: 10.sp, 
                      color: Colors.grey.shade400,
                      height: 1.2
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                else
                   Text(
                    reward.couponType,
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade400),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Spacer(),
                Row(
                  children: [
                     Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(color: Colors.amber.withOpacity(0.5), width: 0.5)
                      ),
                       child: Text(
                        reward.status == 'redeemed' ? 'redeemed'.tr : 'won'.tr,
                        style: TextStyle(fontSize: 10.sp, color: Colors.amber, fontWeight: FontWeight.w600),
                      ),
                     ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpiredContent() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEF5350), // Red 400
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFEF5350), // Red 400
                Color(0xFFE53935), // Red 600
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.sentiment_dissatisfied, color: Colors.white, size: 32.sp), 
                ),
                SizedBox(height: 12.h),
                Text(
                  "expired".tr,
                  style: TextStyle(
                    fontSize: 16.sp, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white
                  ),
                ),
              ],
            ),
          ),
        ),
        // Decorative background icons
        Positioned(
          top: -10, left: -10,
          child: Icon(Icons.history, size: 80.sp, color: Colors.black.withOpacity(0.1)),
        ),
        Positioned(
          bottom: -10, right: -10,
          child: Icon(Icons.highlight_off, size: 80.sp, color: Colors.black.withOpacity(0.1)),
        ),
      ],
    );
  }

  Widget _buildRevealedContent(RewardModel reward) {
    return Container(
      width: 300.w,
      constraints: BoxConstraints(minHeight: 300.w),
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (reward.image != null && reward.image!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: CachedNetworkImage(
                    imageUrl: reward.image!,
                    height: 100.h,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Container(
                      height: 100.h,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) =>
                        Icon(Icons.emoji_events, color: Colors.amber, size: 60.sp),
                  ),
                )
              else
                Icon(Icons.emoji_events, color: Colors.amber, size: 60.sp),
              SizedBox(height: 16.h),
              Text(
                reward.couponType,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: MaruttiColors.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              if (reward.description != null && reward.description!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  reward.description!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: 8.h),
              Text(
                "congratulations".tr,
                style: TextStyle(fontSize: 16.sp, color: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRazorPayDialog(BuildContext context, String amount) {
    // Implementation for RazorPay if needed, or remove if unused.
    // Kept as placeholder if original code had similar intent, but not seen in snippet.
  }

  void _showRewardDetailsDialog(BuildContext context, RewardModel reward) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          backgroundColor: Colors.transparent,
          child: Container(
            width: 300.w,
            height: 350.w, // Slightly taller to accommodate content
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                _buildRevealedContent(reward),
                Positioned(
                  right: 8.w,
                  top: 8.w,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showScratchDialog(BuildContext context, RewardModel reward, RewardsController controller) {
    final scratchKey = GlobalKey<ScratcherState>();
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          backgroundColor: Colors.transparent,
          child: Container(
            width: 300.w,
            height: 300.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            clipBehavior: Clip.hardEdge,
            child: Scratcher(
              key: scratchKey,
              brushSize: 50,
              threshold: 20, // 5% threshold as requested
              color: Colors.blueAccent,
              onChange: (value) {},
              onThreshold: () {
                controller.onScratch(reward);
                scratchKey.currentState?.reveal(duration: const Duration(milliseconds: 500));
              },
              child: _buildRevealedContent(reward),
            ),
          ),
        );
      },
    );
  }
}
