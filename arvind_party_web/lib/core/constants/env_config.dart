// ═══════════════════════════════════════════════════════════════════════════
// ARVIND PARTY WEB PANEL - Environment Configuration
// ═══════════════════════════════════════════════════════════════════════════
// This is the canonical env config. Copy env_config_template.dart to this
// file and fill in your real values. DO NOT commit this file.
// ═══════════════════════════════════════════════════════════════════════════

class EnvConfig {
  // ─── API BASE URL ───────────────────────────────────────────────────
  // Development: http://192.168.1.100:5000/api
  // Production:  https://api.arvindparty.com/api
  static const String apiBaseUrl = 'http://INSERT_YOUR_BACKEND_IP_HERE:5000/api';

  // ─── SOCKET.IO URL ──────────────────────────────────────────────────
  static const String socketUrl = 'http://INSERT_YOUR_BACKEND_IP_HERE:5000';

  // ─── FIREBASE CONFIG ────────────────────────────────────────────────
  static const Map<String, dynamic> firebaseConfig = {
    'apiKey': 'INSERT_YOUR_FIREBASE_API_KEY_HERE',
    'authDomain': 'INSERT_YOUR_FIREBASE_AUTH_DOMAIN_HERE',
    'projectId': 'INSERT_YOUR_FIREBASE_PROJECT_ID_HERE',
    'storageBucket': 'INSERT_YOUR_FIREBASE_STORAGE_BUCKET_HERE',
    'messagingSenderId': 'INSERT_YOUR_FIREBASE_SENDER_ID_HERE',
    'appId': 'INSERT_YOUR_FIREBASE_APP_ID_HERE',
    'measurementId': 'INSERT_YOUR_FIREBASE_MEASUREMENT_ID_HERE',
  };

  // ─── RAZORPAY ───────────────────────────────────────────────────────
  static const String razorpayKeyId = 'INSERT_YOUR_RAZORPAY_KEY_ID_HERE';

  // ─── AGORA ──────────────────────────────────────────────────────────
  static const String agoraAppId = 'INSERT_YOUR_AGORA_APP_ID_HERE';

  // ─── APP DEFAULTS ───────────────────────────────────────────────────
  static const String appName = 'Arvind Party Admin';
  static const String appVersion = '1.0.0';
  static const int pageSize = 20;
  static const int requestTimeoutSeconds = 30;
}