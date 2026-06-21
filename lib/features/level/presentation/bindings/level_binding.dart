// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/level/presentation/bindings/level_binding.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../controllers/level_controller.dart';

class LevelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LevelController>(() => LevelController());
  }
}