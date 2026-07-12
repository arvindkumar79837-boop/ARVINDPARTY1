// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/blind_date/presentation/bindings/blind_date_binding.dart
// ARVIND PARTY - BLIND DATE BINDING
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../controllers/blind_date_controller.dart';
import '../repositories/blind_date_repository.dart';

class BlindDateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BlindDateRepository>(() => BlindDateRepository());
    Get.lazyPut<BlindDateController>(() => BlindDateController(Get.find<BlindDateRepository>()));
  }
}
