// ═══════════════════════════════════════════════════════════════════════════
// WEB PANEL - ENVIRONMENT CONFIGURATION TEMPLATE
// ═══════════════════════════════════════════════════════════════════════════
// Copy this file to `env_config.dart` in the same directory.
// The `env_config.dart` file should be in your .gitignore and NEVER be committed.

import 'package:firebase_core/firebase_core.dart';

class EnvConfig {
  /// The base URL for the backend API.
  static const String apiBaseUrl = 'http://localhost:5000/api';
  
  /// Firebase options for the web app.
  /// Replace all 'YOUR_...' values with your actual Firebase project credentials.
  static const FirebaseOptions firebaseOptions = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    appId: 'YOUR_WEB_APP_ID',
  );
}
