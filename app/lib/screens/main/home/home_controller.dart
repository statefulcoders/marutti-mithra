import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maruttimitra/models/remote/catalogue_model.dart';
import 'package:maruttimitra/overlays/app_snackbar.dart';
import 'package:maruttimitra/utils/extras_table_helper.dart';
import '../../../utils/user_table_helper.dart';

class HomeController extends GetxController {
  final catalogues = Rxn<List<CatalogueModel>>();
  final videos = Rxn<List<String>>();
  final RxBool showBreakdown = false.obs;

  @override
  void onInit() {
    reloadOtherData();
    super.onInit();
  }

  String get formattedTotalPoints => NumberFormat.decimalPattern().format([
    UserTableHelper.user.value?.maPoints ?? 0,
    UserTableHelper.user.value?.vcPoints ?? 0,
    UserTableHelper.user.value?.mwPoints ?? 0,
    UserTableHelper.user.value?.hpPoints ?? 0,
  ].fold(0, (a, b) => a + b));

  Future<void> reloadOtherData() async {
    try {
      final data = await Future.wait([
        ExtrasTableHelper.getCatalogues(),
        ExtrasTableHelper.getVideos()
      ]);
      catalogues.value = data.first.cast<CatalogueModel>();
      videos.value = data.last.cast<String>();
    } catch (error) {
      catalogues.value = [];
      videos.value = [];
      AppSnackBar.error(error.toString());
    }
  }

}