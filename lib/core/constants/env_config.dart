// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/core/constants/env_config.dart
// ARVIND PARTY - CENTRALIZED ENVIRONMENT CONFIGURATION
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';

class EnvConfig {
  EnvConfig._();

  // ─── ENVIRONMENT SELECTION ─────────────────────────────────────────
  static const bool isProduction = true;
  static const bool isStaging = false;
  static const bool isDevelopment = false;

  // ─── BASE URLS ──────────────────────────────────────────────────────
  //
  // Production uses HTTPS with the arvindparty.com domain.
  // Dev/Staging use the test server IP for local development.
  //
  static const String devBaseUrl = 'http://222.167.207.78:5000';
  static const String stagingBaseUrl = 'http://222.167.207.78:5000';
  static const String prodBaseUrl = 'https://api.arvindparty.com';

  // ─── RESOLVED URL ───────────────────────────────────────────────────
  static String get currentEnv => isProduction ? 'production' : isStaging ? 'staging' : 'development';

  static String get baseUrl =>
      isProduction ? prodBaseUrl : isStaging ? stagingBaseUrl : devBaseUrl;

  /// API base URL (used by ApiService via ApiConstants)
  static String get apiBaseUrl => '$baseUrl/api';

  /// Socket server URL (used by SocketService and repositories)
  static String get socketUrl => baseUrl;

  /// Plain API base URL without version suffix
  static String get plainApiBaseUrl => '$baseUrl/api';

  // ─── TIMEOUTS ──────────────────────────────────────────────────────
  // Testing server ke liye generous timeouts rakhe hain.
  // Production mein isse kam kar sakte ho.
  static const int connectionTimeoutMs = 30000;
  static const int receiveTimeoutMs = 30000;
  static const int sendTimeoutMs = 30000;

  // ─── FEATURE FLAGS ──────────────────────────────────────────────────
  static const bool enableAnalytics = false;
  static bool get enableCrashReporting => isProduction;
  static bool get enableDebugLogging => kDebugMode;
  static const int maxRetryAttempts = 3;

  // ─── STORAGE KEYS ──────────────────────────────────────────────────
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userNameKey = 'user_name';
  static const String userAvatarKey = 'user_avatar';
  static const String userPhoneKey = 'user_phone';
  static const String userEmailKey = 'user_email';
  static const String loggedInKey = 'is_logged_in';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String firstOpenKey = 'first_open';
  static const String deviceIdKey = 'device_id';

  // ─── SECURITY ──────────────────────────────────────────────────────
  static const int tokenRefreshThresholdMs = 300000; // 5 min before expiry
  static const int maxLoginAttempts = 5;
  static const int sessionTimeoutHours = 24;

  // ─── LIVEKIT ────────────────────────────────────────────────────────
  static String get liveKitApiBaseUrl => baseUrl;
  static const String liveKitWsUrl = 'wss://livekit.arvindparty.com';
  static String get liveKitTokenPath => '/room';

  // ─── COMMISSION RATES ─────────────────────────────────────────────
  static const double giftCommissionRate = 0.70;
  static const double agencyCommissionRate = 0.15;
  static const double platformCommissionRate = 0.15;
}
