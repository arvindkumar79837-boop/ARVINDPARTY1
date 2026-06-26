// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/power_matrix/presentation/bindings/power_matrix_binding.dart
// ARVIND PARTY - POWER MATRIX BINDING
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../controllers/power_matrix_controller.dart';

class PowerMatrixBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PowerMatrixController>(() => PowerMatrixController());
  }
}