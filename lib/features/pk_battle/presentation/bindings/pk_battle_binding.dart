// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/pk_battle/presentation/bindings/pk_battle_binding.dart
// ARVIND PARTY - PK BATTLE BINDING
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../controllers/pk_battle_controller.dart';

class PkBattleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PkBattleController>(() => PkBattleController());
  }
}
