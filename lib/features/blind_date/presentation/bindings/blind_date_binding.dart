// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/blind_date/presentation/bindings/blind_date_binding.dart
// ARVIND PARTY - BLIND DATE BINDING
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../controllers/blind_date_controller.dart';

class BlindDateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BlindDateController>(() => BlindDateController());
  }
}