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

  // ─── API URLs ──────────────────────────────────────────────────────
  static String get currentEnv => isProduction ? 'production' : isStaging ? 'staging' : 'development';

  // Fallback dev URL for physical device on same LAN
  // ⚠️ CONFIGURE YOUR BACKEND URL HERE — REPLACE WITH YOUR ACTUAL DEV SERVER IP
  static const String devBaseUrl = 'http://222.167.207.78:3000';
  static const String stagingBaseUrl = 'https://staging-api.arvind-party.com';
  static const String prodBaseUrl = 'http://222.167.207.78:3000';

  /// Returns the effective base URL.
  /// Since we are in production mode, this always resolves to prodBaseUrl.
  /// The platform-specific localhost fallbacks are removed to ensure no
  /// accidental local routing occurs.
  static String get effectiveDevBaseUrl => prodBaseUrl;

  static String get baseUrl => isProduction ? prodBaseUrl : isStaging ? stagingBaseUrl : effectiveDevBaseUrl;

  /// API base URL (used by ApiService via ApiConstants)
  static String get apiBaseUrl => '$baseUrl/api';

  /// Socket server URL (used by SocketService and repositories)
  static String get socketUrl => baseUrl;

  /// Plain API base URL without version suffix (for repositories using direct Dio calls)
  static String get plainApiBaseUrl => '$baseUrl/api';

  // ─── TIMEOUTS ──────────────────────────────────────────────────────
  static const int connectionTimeoutMs = 30000;
  static const int receiveTimeoutMs = 30000;
  static const int sendTimeoutMs = 30000;

  // ─── FEATURE FLAGS ──────────────────────────────────────────────────
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;
  static const bool enableDebugLogging = true;
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

  // ─── LIVEKIT ──────────────────────────────────────────────────────────
  // LiveKit server/API base (used for token fetching)
  static String get liveKitApiBaseUrl => baseUrl;

  /// LiveKit WebSocket URL for client connections — REPLACE WITH YOUR LIVEKIT DOMAIN
  static const String liveKitWsUrl = 'wss://YOUR_LIVEKIT_DOMAIN';

  /// If your mobile client negotiates tokens from backend using a room ref, keep this path aligned with backend route.
  static String get liveKitTokenPath => '/room';
}
