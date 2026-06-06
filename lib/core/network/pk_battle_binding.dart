import 'package:get/get.dart';
import '../controllers/pk_battle_controller.dart';

class PkBattleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PkBattleController>(() => PkBattleController());
  }
}
