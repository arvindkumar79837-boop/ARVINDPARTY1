// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/agency/presentation/bindings/agency_binding.dart
// ARVIND PARTY - AGENCY BINDING
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../controllers/agency_controller.dart';
import '../repositories/agency_repository.dart';

class AgencyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AgencyRepository>(() => AgencyRepository());
    Get.lazyPut<AgencyController>(() => AgencyController());
  }
}