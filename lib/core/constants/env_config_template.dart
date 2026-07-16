// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/core/constants/env_config_template.dart
// ARVIND PARTY - ENVIRONMENT CONFIGURATION TEMPLATE
// ═══════════════════════════════════════════════════════════════════════════
// Copy this file to env_config.dart and update the values below.
// DO NOT commit env_config.dart to version control — it contains secrets.
// ═══════════════════════════════════════════════════════════════════════════

class EnvConfig {
  EnvConfig._();

  // ─── ENVIRONMENT SELECTION ─────────────────────────────────────────
  // Set only ONE to true:
  static const bool isProduction = false;
  static const bool isStaging = false;
  static const bool isDevelopment = true;

  // ─── API URLs ──────────────────────────────────────────────────────
  // Replace with your actual server URLs
  static const String devBaseUrl = 'http://localhost:3000';
  static const String stagingBaseUrl = 'https://staging-api.yourdomain.com';
  static const String prodBaseUrl = 'https://api.yourdomain.com';

  static String get currentEnv => isProduction ? 'production' : isStaging ? 'staging' : 'development';
  static String get effectiveDevBaseUrl => devBaseUrl;

  static String get baseUrl => isProduction ? prodBaseUrl : isStaging ? stagingBaseUrl : effectiveDevBaseUrl;
  static String get apiBaseUrl => '$baseUrl/api';
  static String get socketUrl => baseUrl;
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
  static const int tokenRefreshThresholdMs = 300000;
  static const int maxLoginAttempts = 5;
  static const int sessionTimeoutHours = 24;

  // ─── LIVEKIT ──────────────────────────────────────────────────────────
  // Replace with your actual LiveKit WebSocket URL
  static String get liveKitApiBaseUrl => baseUrl;
  static const String liveKitWsUrl = 'wss://livekit.yourdomain.com';
  static String get liveKitTokenPath => '/room';

  // ─── COMMISSION RATES ─────────────────────────────────────────────
  static const double giftCommissionRate = 0.70;
  static const double agencyCommissionRate = 0.15;
  static const double platformCommissionRate = 0.15;
}
