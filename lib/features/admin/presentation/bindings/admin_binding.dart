// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/admin/presentation/bindings/admin_binding.dart
// ARVIND PARTY - ADMIN BINDING
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../controllers/admin_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminController>(() => AdminController());
  }
}