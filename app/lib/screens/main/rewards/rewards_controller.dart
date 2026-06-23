import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:maruttimitra/models/remote/reward_model.dart';
import 'package:maruttimitra/utils/settings/marutti_session_memory.dart';

class RewardsController extends GetxController {
  final rewards = Rxn<List<RewardModel>>();

  @override
  void onInit() {
    super.onInit();
    fetchRewards();
  }

  Future<void> fetchRewards() async {
    try {
      final uid = MaruttiSessionMemory.uid;
      if (uid == null) {
        rewards.value = [];
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('rewarded_users')
          .where('uid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();

      rewards.value = snapshot.docs.map((doc) => RewardModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching rewards: $e');
      rewards.value = [];
    }
  }

  Future<void> onScratch(RewardModel reward) async {
    try {
      await FirebaseFirestore.instance
          .collection('rewarded_users')
          .doc(reward.id)
          .update({'status': 'scratched'});
      
      // Refresh list or update local model? Refresh is safer/easier
      // But for better UX we might want to just update the local list
       final index = rewards.value?.indexWhere((r) => r.id == reward.id) ?? -1;
       if (index != -1 && rewards.value != null) {
          // Create new list to trigger Obx
          final newList = List<RewardModel>.from(rewards.value!);
           // Manually update the item in list to reflect scratched status without refetching immediately
           // Note: RewardModel is immutable, need to replace it. But we don't have copyWith.
           // Since we just need it to show result, triggering fetchRewards is acceptable but might be slow.
           // Let's just refetch for now to be sure.
           fetchRewards();
       }
    } catch (e) {
      print('Error scratching reward: $e');
    }
  }
}
