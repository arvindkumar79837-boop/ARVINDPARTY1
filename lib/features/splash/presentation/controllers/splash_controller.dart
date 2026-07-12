// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/splash/presentation/controllers/splash_controller.dart
// ARVIND PARTY - SPLASH CONTROLLER (with timeout safety)
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../../core/services/auth_session_manager.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    try {
      // Safety timeout: agar kuch bhi hang ho toh 6 seconds mein force navigate
      await Future.delayed(const Duration(seconds: 2)).timeout(
        const Duration(seconds: 6),
        onTimeout: () => throw TimeoutException('Splash timeout'),
      );
      
      final authSession = Get.find<AuthSessionManager>();
      if (authSession.hasToken()) {
        Get.offAllNamed('/home');
      } else {
        Get.offAllNamed('/login');
      }
    } catch (e) {
      debugPrint('⚠️ Splash error (navigating to login): $e');
      // Fallback: agar kuch bhi fail ho toh login screen dikhao
      Get.offAllNamed('/login');
    }
  }
}
