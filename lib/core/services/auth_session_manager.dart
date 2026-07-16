// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/core/services/auth_session_manager.dart
// ARVIND PARTY - AUTHENTICATION SESSION MANAGER WITH TOKEN REFRESH
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../constants/env_config.dart';
import '../services/api_service.dart';
import '../../routes/app_routes.dart';

/// Reactive authentication status for driving splash → login/home transitions.
/// Initial state is [unknown]; after session load it transitions to either
/// [authenticated] or [unauthenticated]. This guarantees a detectable change
/// on every app start — unlike a raw `bool` that may stay `false → false`.
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthSessionManager extends GetxService {
  static AuthSessionManager get to => Get.find<AuthSessionManager>();

  // Secure storage for sensitive data
  static const _secureStorage = FlutterSecureStorage();

  // Session state
  var token = Rxn<String>();
  var refreshToken = Rxn<String>();
  var userId = Rxn<String>();
  var userName = Rxn<String>();
  var userEmail = Rxn<String>();
  var userPhone = Rxn<String>();
  var userAvatar = Rxn<String>();

  // Observables

  /// Reactive auth status — drives splash-to-login/home navigation.
  /// Initial value is [AuthStatus.unknown]; transitions once _loadSession() completes.
  final Rx<AuthStatus> authStatus = AuthStatus.unknown.obs;

  /// Backwards-compatible convenience getter.
  bool get isLoggedIn => authStatus.value == AuthStatus.authenticated;

  final isTokenRefreshing = false.obs;
  final refreshAttempts = 0.obs;

  // Timers
  Timer? _tokenRefreshTimer;
  Timer? _sessionCheckTimer;

  // Constants
  static const int _maxRefreshAttempts = 3;
  static const int _sessionCheckIntervalMs = 60000; // Check every minute

  // Controllers
  late ApiService _api;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiService>();
    _loadSession();
    _startSessionMonitor();
  }

  @override
  void onClose() {
    _tokenRefreshTimer?.cancel();
    _sessionCheckTimer?.cancel();
    super.onClose();
  }

  // ═══════ SESSION MANAGEMENT ══════════════════════════════════════════════

  /// Load session from storage
  Future<void> _loadSession() async {
    try {
      
      
      token.value = await _secureStorage.read(key: EnvConfig.tokenKey);
      refreshToken.value = await _secureStorage.read(key: EnvConfig.refreshTokenKey);
      userId.value = await _secureStorage.read(key: EnvConfig.userIdKey);
      userName.value = await _secureStorage.read(key: EnvConfig.userNameKey);
      userEmail.value = await _secureStorage.read(key: EnvConfig.userEmailKey);
      userPhone.value = await _secureStorage.read(key: EnvConfig.userPhoneKey);
      userAvatar.value = await _secureStorage.read(key: EnvConfig.userAvatarKey);

      final tokenExists = token.value != null && token.value!.isNotEmpty;
      authStatus.value = tokenExists ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      
    } catch (e) {
      authStatus.value = AuthStatus.unauthenticated;
    }
  }

  /// Save session to storage
  Future<void> saveSession({
    required String token,
    String? refreshTokenValue,
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? userAvatar,
    bool isGuest = false,
  }) async {
    try {
      
      
      this.token.value = token;
      refreshToken.value = refreshTokenValue;
      this.userId.value = userId;
      this.userName.value = userName;
      this.userEmail.value = userEmail;
      this.userPhone.value = userPhone;
      this.userAvatar.value = userAvatar;

      await _secureStorage.write(key: EnvConfig.tokenKey, value: token);
      if (refreshTokenValue != null) {
        await _secureStorage.write(key: EnvConfig.refreshTokenKey, value: refreshTokenValue);
      }
      if (userId != null) await _secureStorage.write(key: EnvConfig.userIdKey, value: userId);
      if (userName != null) await _secureStorage.write(key: EnvConfig.userNameKey, value: userName);
      if (userEmail != null) await _secureStorage.write(key: EnvConfig.userEmailKey, value: userEmail);
      if (userPhone != null) await _secureStorage.write(key: EnvConfig.userPhoneKey, value: userPhone);
      if (userAvatar != null) await _secureStorage.write(key: EnvConfig.userAvatarKey, value: userAvatar);
      await _secureStorage.write(key: 'is_guest', value: isGuest.toString());

      authStatus.value = AuthStatus.authenticated;
      
      // Schedule token refresh
      _scheduleTokenRefresh();
      
    } catch (e) {
    }
  }

  /// Clear session (logout)
  Future<void> clearSession() async {
    try {
      
      
      await _secureStorage.delete(key: EnvConfig.tokenKey);
      await _secureStorage.delete(key: EnvConfig.refreshTokenKey);
      await _secureStorage.delete(key: EnvConfig.userIdKey);
      await _secureStorage.delete(key: EnvConfig.userNameKey);
      await _secureStorage.delete(key: EnvConfig.userEmailKey);
      await _secureStorage.delete(key: EnvConfig.userPhoneKey);
      await _secureStorage.delete(key: EnvConfig.userAvatarKey);

      token.value = null;
      refreshToken.value = null;
      userId.value = null;
      userName.value = null;
      userEmail.value = null;
      userPhone.value = null;
      userAvatar.value = null;

      authStatus.value = AuthStatus.unauthenticated;
      refreshAttempts.value = 0;

      _tokenRefreshTimer?.cancel();
      
    } catch (e) {
    }
  }

  bool hasToken() {
    return token.value != null && token.value!.isNotEmpty;
  }

  // ═══════ TOKEN REFRESH ══════════════════════════════════════════════════

  /// Schedule automatic token refresh
  void _scheduleTokenRefresh() {
    _tokenRefreshTimer?.cancel();
    
    // Refresh token 5 minutes before expiry (assume 1 hour token lifetime)
    _tokenRefreshTimer = Timer(
      const Duration(minutes: 55),
      () => _refreshAccessToken(),
    );
    
  }

  /// Start session monitor
  void _startSessionMonitor() {
    _sessionCheckTimer?.cancel();
    _sessionCheckTimer = Timer.periodic(
      const Duration(milliseconds: _sessionCheckIntervalMs),
      (_) => _checkSession(),
    );
  }

  /// Check session validity
  Future<void> _checkSession() async {
    if (!isLoggedIn || token.value == null) {
      return;
    }

    // Check if token needs refresh
    final needsRefresh = refreshAttempts.value < _maxRefreshAttempts;
    if (needsRefresh) {
      // Optionally verify token with server
      // For now, we rely on 401 responses to trigger refresh
    }
  }

  /// Refresh access token using refresh token
  Future<bool> _refreshAccessToken() async {
    if (isTokenRefreshing.value) {
      return false;
    }

    final currentRefreshToken = refreshToken.value;
    if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
      await clearSession();
      return false;
    }

    if (refreshAttempts.value >= _maxRefreshAttempts) {
      await clearSession();
      Get.offAllNamed(AppRoutes.login);
      return false;
    }

    try {
      isTokenRefreshing.value = true;
      refreshAttempts.value++;


      final response = await _api.post(
        '/auth/refresh-token',
        body: {
          'refreshToken': currentRefreshToken,
        },
      );

      final newToken = response['token'];
      final newRefreshToken = response['refreshToken'];

      if (newToken != null) {
        await saveSession(
          token: newToken,
          refreshTokenValue: newRefreshToken ?? currentRefreshToken,
          userId: userId.value,
          userName: userName.value,
          userEmail: userEmail.value,
          userPhone: userPhone.value,
          userAvatar: userAvatar.value,
        );

        refreshAttempts.value = 0;
        _scheduleTokenRefresh();

        return true;
      } else {
        await clearSession();
        Get.offAllNamed(AppRoutes.login);
        return false;
      }
    } catch (e) {
      
      // If refresh fails, clear session
      if (refreshAttempts.value >= _maxRefreshAttempts - 1) {
        await clearSession();
        Get.offAllNamed(AppRoutes.login);
      }
      
      return false;
    } finally {
      isTokenRefreshing.value = false;
    }
  }

  /// Handle 401 Unauthorized response
  Future<void> handleUnauthorized() async {
    
    // Try to refresh token
    final refreshed = await _refreshAccessToken();
    
    if (!refreshed) {
      await clearSession();
      Get.offAllNamed(AppRoutes.login);
    }
  }

  // ═══════ DEVICE FINGERPRINTING ══════════════════════════════════════════

  /// Generate device fingerprint
  Future<String> getDeviceFingerprint() async {
    try {
      
      final cached = await _secureStorage.read(key: 'device_fingerprint');
      
      if (cached != null && cached.isNotEmpty) {
        return cached;
      }

      // Generate new fingerprint
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final random = DateTime.now().microsecond.toString();
      final data = '${userId.value ?? ""}$timestamp$random';
      final bytes = utf8.encode(data);
      final hash = sha256.convert(bytes);
      final fingerprint = hash.toString().substring(0, 32);

      await _secureStorage.write(key: 'device_fingerprint', value: fingerprint);
      
      return fingerprint;
    } catch (e) {
      return 'unknown';
    }
  }

  // ═══════ UTILITY METHODS ════════════════════════════════════════════════

  /// Get authorization header
  Future<Map<String, String>> getAuthHeaders() async {
    final headers = <String, String>{};
    
    if (token.value != null) {
      headers['Authorization'] = 'Bearer ${token.value}';
    }

    // Add device fingerprint
    final fingerprint = await getDeviceFingerprint();
    if (fingerprint != 'unknown') {
      headers['X-Device-Fingerprint'] = fingerprint;
    }

    return headers;
  }

  /// Update user info
  Future<void> updateUserInfo({
    String? userName,
    String? userEmail,
    String? userPhone,
    String? userAvatar,
  }) async {
    
    
    if (userName != null) {
      this.userName.value = userName;
      await _secureStorage.write(key: EnvConfig.userNameKey, value: userName);
    }
    if (userEmail != null) {
      this.userEmail.value = userEmail;
      await _secureStorage.write(key: EnvConfig.userEmailKey, value: userEmail);
    }
    if (userPhone != null) {
      this.userPhone.value = userPhone;
      await _secureStorage.write(key: EnvConfig.userPhoneKey, value: userPhone);
    }
    if (userAvatar != null) {
      this.userAvatar.value = userAvatar;
      await _secureStorage.write(key: EnvConfig.userAvatarKey, value: userAvatar);
    }
  }

  /// Check if session is valid
  bool isValid() {
    return isLoggedIn && token.value != null;
  }
}