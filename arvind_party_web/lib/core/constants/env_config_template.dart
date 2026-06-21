// ═══════════════════════════════════════════════════════════════════════════
// ARVIND PARTY WEB PANEL - Environment Configuration Template
// ═══════════════════════════════════════════════════════════════════════════
// INSTRUCTIONS: Copy this file to env_config.dart, then fill in your values.
// DO NOT commit env_config.dart to version control.
// ═══════════════════════════════════════════════════════════════════════════

class EnvConfig {
  // ─── API BASE URL ───────────────────────────────────────────────────
  // INSERT YOUR BACKEND API URL HERE
  // Development: http://192.168.1.100:5000/api
  // Production:  https://api.arvindparty.com/api
  static const String apiBaseUrl = 'http://INSERT_YOUR_BACKEND_IP_HERE:5000/api';

  // ─── SOCKET.IO URL ──────────────────────────────────────────────────
  // INSERT YOUR SOCKET.IO SERVER URL HERE
  static const String socketUrl = 'http://INSERT_YOUR_BACKEND_IP_HERE:5000';

  // ─── FIREBASE CONFIG ────────────────────────────────────────────────
  // INSERT YOUR FIREBASE WEB APP CONFIG HERE
  // Go to Firebase Console > Project Settings > General > Your apps > Web app
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
  // INSERT YOUR RAZORPAY KEY ID HERE
  static const String razorpayKeyId = 'INSERT_YOUR_RAZORPAY_KEY_ID_HERE';

  // ─── AGORA ──────────────────────────────────────────────────────────
  // INSERT YOUR AGORA APP ID HERE
  static const String agoraAppId = 'INSERT_YOUR_AGORA_APP_ID_HERE';

  // ─── APP DEFAULTS ───────────────────────────────────────────────────
  static const String appName = 'Arvind Party Admin';
  static const String appVersion = '1.0.0';
  static const int pageSize = 20;
  static const int requestTimeoutSeconds = 30;
}