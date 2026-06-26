// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/core/services/auth_session_manager.dart
// ARVIND PARTY - AUTHENTICATION SESSION MANAGER WITH TOKEN REFRESH
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/env_config.dart';
import '../services/api_service.dart';

class AuthSessionManager extends GetxService {
  static AuthSessionManager get to => Get.find<AuthSessionManager>();

  // Session state
  var token = Rxn<String>();
  var refreshToken = Rxn<String>();
  var userId = Rxn<String>();
  var userName = Rxn<String>();
  var userEmail = Rxn<String>();
  var userPhone = Rxn<String>();
  var userAvatar = Rxn<String>();

  // Observables
  final isLoggedIn = false.obs;
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
      final prefs = await SharedPreferences.getInstance();
      
      token.value = prefs.getString(EnvConfig.tokenKey);
      refreshToken.value = prefs.getString(EnvConfig.refreshTokenKey);
      userId.value = prefs.getString(EnvConfig.userIdKey);
      userName.value = prefs.getString(EnvConfig.userNameKey);
      userEmail.value = prefs.getString(EnvConfig.userEmailKey);
      userPhone.value = prefs.getString(EnvConfig.userPhoneKey);
      userAvatar.value = prefs.getString(EnvConfig.userAvatarKey);

      isLoggedIn.value = token.value != null && token.value!.isNotEmpty;
      
      debugPrint('[AuthSession] Session loaded: ${isLoggedIn.value ? "Logged in" : "Not logged in"}');
    } catch (e) {
      debugPrint('[AuthSession] Load error: $e');
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
      final prefs = await SharedPreferences.getInstance();
      
      this.token.value = token;
      refreshToken.value = refreshTokenValue;
      this.userId.value = userId;
      this.userName.value = userName;
      this.userEmail.value = userEmail;
      this.userPhone.value = userPhone;
      this.userAvatar.value = userAvatar;

      await prefs.setString(EnvConfig.tokenKey, token);
      if (refreshTokenValue != null) {
        await prefs.setString(EnvConfig.refreshTokenKey, refreshTokenValue);
      }
      if (userId != null) await prefs.setString(EnvConfig.userIdKey, userId);
      if (userName != null) await prefs.setString(EnvConfig.userNameKey, userName);
      if (userEmail != null) await prefs.setString(EnvConfig.userEmailKey, userEmail);
      if (userPhone != null) await prefs.setString(EnvConfig.userPhoneKey, userPhone);
      if (userAvatar != null) await prefs.setString(EnvConfig.userAvatarKey, userAvatar);
      await prefs.setBool('is_guest', isGuest);

      isLoggedIn.value = true;
      
      // Schedule token refresh
      _scheduleTokenRefresh();
      
      debugPrint('[AuthSession] Session saved for user: $userId');
    } catch (e) {
      debugPrint('[AuthSession] Save error: $e');
    }
  }

  /// Clear session (logout)
  Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.remove(EnvConfig.tokenKey);
      await prefs.remove(EnvConfig.refreshTokenKey);
      await prefs.remove(EnvConfig.userIdKey);
      await prefs.remove(EnvConfig.userNameKey);
      await prefs.remove(EnvConfig.userEmailKey);
      await prefs.remove(EnvConfig.userPhoneKey);
      await prefs.remove(EnvConfig.userAvatarKey);

      token.value = null;
      refreshToken.value = null;
      userId.value = null;
      userName.value = null;
      userEmail.value = null;
      userPhone.value = null;
      userAvatar.value = null;

      isLoggedIn.value = false;
      refreshAttempts.value = 0;

      _tokenRefreshTimer?.cancel();
      
      debugPrint('[AuthSession] Session cleared');
    } catch (e) {
      debugPrint('[AuthSession] Clear error: $e');
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
    
    debugPrint('[AuthSession] Token refresh scheduled');
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
    if (!isLoggedIn.value || token.value == null) {
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
      debugPrint('[AuthSession] Refresh already in progress');
      return false;
    }

    final currentRefreshToken = refreshToken.value;
    if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
      debugPrint('[AuthSession] No refresh token available');
      await clearSession();
      return false;
    }

    if (refreshAttempts.value >= _maxRefreshAttempts) {
      debugPrint('[AuthSession] Max refresh attempts reached');
      await clearSession();
      Get.offAllNamed('/login');
      return false;
    }

    try {
      isTokenRefreshing.value = true;
      refreshAttempts.value++;

      debugPrint('[AuthSession] Refreshing token...');

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

        debugPrint('[AuthSession] Token refreshed successfully');
        return true;
      } else {
        debugPrint('[AuthSession] Refresh failed: No token in response');
        await clearSession();
        Get.offAllNamed('/login');
        return false;
      }
    } catch (e) {
      debugPrint('[AuthSession] Refresh error: $e');
      
      // If refresh fails, clear session
      if (refreshAttempts.value >= _maxRefreshAttempts - 1) {
        await clearSession();
        Get.offAllNamed('/login');
      }
      
      return false;
    } finally {
      isTokenRefreshing.value = false;
    }
  }

  /// Handle 401 Unauthorized response
  Future<void> handleUnauthorized() async {
    debugPrint('[AuthSession] Handling 401 Unauthorized');
    
    // Try to refresh token
    final refreshed = await _refreshAccessToken();
    
    if (!refreshed) {
      debugPrint('[AuthSession] Refresh failed, logging out');
      await clearSession();
      Get.offAllNamed('/login');
    }
  }

  // ═══════ DEVICE FINGERPRINTING ══════════════════════════════════════════

  /// Generate device fingerprint
  Future<String> getDeviceFingerprint() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('device_fingerprint');
      
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

      await prefs.setString('device_fingerprint', fingerprint);
      
      return fingerprint;
    } catch (e) {
      debugPrint('[AuthSession] Device fingerprint error: $e');
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
    final prefs = await SharedPreferences.getInstance();
    
    if (userName != null) {
      this.userName.value = userName;
      await prefs.setString(EnvConfig.userNameKey, userName);
    }
    if (userEmail != null) {
      this.userEmail.value = userEmail;
      await prefs.setString(EnvConfig.userEmailKey, userEmail);
    }
    if (userPhone != null) {
      this.userPhone.value = userPhone;
      await prefs.setString(EnvConfig.userPhoneKey, userPhone);
    }
    if (userAvatar != null) {
      this.userAvatar.value = userAvatar;
      await prefs.setString(EnvConfig.userAvatarKey, userAvatar);
    }
  }

  /// Check if session is valid
  bool isValid() {
    return isLoggedIn.value && token.value != null;
  }
}