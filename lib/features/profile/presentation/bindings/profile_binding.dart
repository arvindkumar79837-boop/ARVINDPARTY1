// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/profile/presentation/bindings/profile_binding.dart
// ARVIND PARTY - UNIFIED PROFILE BINDING
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // Current user's profile controller
    Get.lazyPut<ProfileController>(
      () => ProfileController(),
      fenix: true,
    );

    // Other user's profile controller
    Get.lazyPut<OtherUserController>(
      () => OtherUserController(),
      fenix: true,
    );
  }
}