// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/splash/presentation/controllers/splash_controller.dart
// ARVIND PARTY - SPLASH CONTROLLER (Reactive GetX lifecycle — no temporal hacks)
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:get/get.dart';
import '../../../../core/services/auth_session_manager.dart';
import '../../../../routes/app_routes.dart';

class SplashController extends GetxController {
  final AuthSessionManager _authSession = Get.find<AuthSessionManager>();

  /// Reactive loading state for the view to observe.
  final isLoading = true.obs;

  /// Minimum splash display duration — purely cosmetic, not structural.
  static const Duration _minimumDisplay = Duration(seconds: 2);

  /// Timer for the minimum display window.
  Timer? _minimumDisplayTimer;

  /// Completer that resolves when the minimum display window elapses.
  final Completer<void> _minimumDisplayElapsed = Completer<void>();

  /// Worker (cancelled on controller disposal).
  late Worker _authWorker;

  /// Flag to ensure navigation fires exactly once.
  bool _navigated = false;

  @override
  void onInit() {
    super.onInit();

    // Start the minimum-display timer concurrently (purely cosmetic).
    _minimumDisplayTimer = Timer(_minimumDisplay, () {
      if (!_minimumDisplayElapsed.isCompleted) {
        _minimumDisplayElapsed.complete();
      }
    });

    // ── Check current authStatus immediately ────────────────────────────
    // AuthSessionManager is a GetxService registered in main.dart, so its
    // _loadSession() may have already completed by the time this controller
    // is initialized. If authStatus is already resolved (not unknown), we
    // react immediately — no worker needed.
    if (_authSession.authStatus.value != AuthStatus.unknown) {
      _onAuthStatusKnown();
      return;
    }

    // ── Fallback: observe authStatus with ever() ────────────────────────
    // If _loadSession() hasn't finished yet, ever() will fire when the
    // status transitions from unknown → authenticated/unauthenticated.
    _authWorker = ever(
      _authSession.authStatus,
      (AuthStatus status) {
        if (status == AuthStatus.unknown) return; // still loading
        _onAuthStatusKnown();
      },
    );

    // ── Re-check after ever() registration ──────────────────────────────
    // _loadSession() (triggered in AuthSessionManager.onInit()) runs
    // asynchronously. It may have completed between the immediate check
    // at line 49 and the ever() registration above. If so, the status is
    // already resolved but neither path (immediate check nor ever() callback)
    // would have fired. Re-check closes that race window.
    if (_authSession.authStatus.value != AuthStatus.unknown) {
      _onAuthStatusKnown();
    }
  }

  @override
  void onClose() {
    _minimumDisplayTimer?.cancel();
    _authWorker.dispose();
    super.onClose();
  }

  /// Called once the definitive auth status is available.
  void _onAuthStatusKnown() {
    // Wait for minimum display duration before navigating.
    _minimumDisplayElapsed.future.then((_) => _navigate());
  }

  void _navigate() {
    if (_navigated) return;
    _navigated = true;

    isLoading.value = false;

    if (_authSession.authStatus.value == AuthStatus.authenticated) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}