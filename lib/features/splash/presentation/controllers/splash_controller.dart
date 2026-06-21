// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/splash/presentation/controllers/splash_controller.dart
// ARVIND PARTY - SPLASH CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SplashController extends GetxController {
  final _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    final isLoggedIn = _storage.read('token') != null;
    if (isLoggedIn) {
      Get.offAllNamed('/home');
    } else {
      Get.offAllNamed('/login');
    }
  }
}