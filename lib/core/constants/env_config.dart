// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/core/constants/env_config.dart
// ARVIND PARTY - CENTRALIZED ENVIRONMENT CONFIGURATION
// ═══════════════════════════════════════════════════════════════════════════
// Update these URLs before production deployment
class EnvConfig {
  EnvConfig._();

  // ─── ENVIRONMENT SELECTION ─────────────────────────────────────────
  static const bool isProduction = true;
  static const bool isStaging = false;
  static const bool isDevelopment = false;

  // ─── API URLs ──────────────────────────────────────────────────────
  // Update these URLs before production deployment
  static String get currentEnv => isProduction ? 'production' : isStaging ? 'staging' : 'development';

  // Fallback dev URL for physical device on same LAN
  static const String devBaseUrl = 'https://api.arvindparty.com';
  static const String stagingBaseUrl = 'https://staging-api.arvindparty.com';
  static const String prodBaseUrl = 'https://api.arvindparty.com';

  /// Returns the effective base URL.
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

  /// LiveKit WebSocket URL for client connections
  static const String liveKitWsUrl = 'wss://livekit.arvindparty.com';

  /// If your mobile client negotiates tokens from backend using a room ref, keep this path aligned with backend route.
  static String get liveKitTokenPath => '/room';

  // ─── COMMISSION RATES ─────────────────────────────────────────────
  static const double giftCommissionRate = 0.70;
  static const double agencyCommissionRate = 0.15;
  static const double platformCommissionRate = 0.15;
}
