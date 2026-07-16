// ═══════════════════════════════════════════════════════════════════════════
// FEATURE: Splash
// FILE: splash_repository.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';

import '../../../../core/services/auth_session_manager.dart';

class SplashRepository {
  AuthSessionManager get _session => Get.find<AuthSessionManager>();

  /// Initialize app settings or check auth state
  Future<void> initializeApp() async {
    // App initialization handled by individual services
  }

  /// Check if user is authenticated
  Future<bool> isUserAuthenticated() async {
    return _session.isLoggedIn;
  }

  /// Get initial route based on app state
  Future<String> getInitialRoute() async {
    final isAuth = await isUserAuthenticated();
    return isAuth ? '/home' : '/login';
  }
}
