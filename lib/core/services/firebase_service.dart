// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/core/services/firebase_service.dart
// ARVIND PARTY - FIREBASE SERVICE (Auth + Messaging + Cloud)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';

class FirebaseService extends GetxService {
  late FirebaseAuth _auth;
  late FirebaseMessaging _messaging;
  final ApiService _apiService = Get.find<ApiService>();

  // Reactive states
  final isInitialized = false.obs;
  final currentUser = Rxn<User>();
  final fcmToken = Rxn<String>();
  final pushNotificationsEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeFirebase();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // INITIALIZATION
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _initializeFirebase() async {
    try {
      _auth = FirebaseAuth.instance;
      _messaging = FirebaseMessaging.instance;

      // Request notification permissions
      await _requestNotificationPermissions();

      // Get and store FCM token
      final token = await _messaging.getToken();
      fcmToken.value = token;

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        fcmToken.value = newToken;
        _syncFCMTokenToBackend(newToken);
      });

      // Handle foreground notifications
      FirebaseMessaging.onMessage.listen(_handleForegroundNotification);

      // Handle background notifications
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundNotification);

      // Sync user to local state
      _auth.authStateChanges().listen((User? user) {
        currentUser.value = user;
      });

      isInitialized.value = true;
      debugPrint('✅ Firebase initialized successfully');
    } catch (e) {
      debugPrint('❌ Firebase initialization error: $e');
      isInitialized.value = false;
    }
  }

  Future<void> _requestNotificationPermissions() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      pushNotificationsEnabled.value =
          settings.authorizationStatus == AuthorizationStatus.authorized;

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ User granted notification permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        debugPrint('⚠️ User granted provisional notification permission');
      } else {
        debugPrint('❌ User denied notification permission');
      }
    } catch (e) {
      debugPrint('⚠️ Error requesting notification permissions: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // NOTIFICATION HANDLERS
  // ─────────────────────────────────────────────────────────────────────────

  void _handleForegroundNotification(RemoteMessage message) {
    debugPrint('📬 Foreground notification: ${message.notification?.title}');
    // Handle foreground notification display
    // Could show local notification or snackbar
  }

  void _handleBackgroundNotification(RemoteMessage message) {
    debugPrint('📬 Background notification opened: ${message.notification?.title}');
    // Navigate to relevant screen based on message data
    _navigateBasedOnNotification(message);
  }

  void _navigateBasedOnNotification(RemoteMessage message) {
    // Parse notification data and navigate
    final data = message.data;
    final type = data['type'];

    // Example navigation logic
    switch (type) {
      case 'gift':
        Get.toNamed('/gift-received', arguments: data);
        break;
      case 'message':
        Get.toNamed('/chat', arguments: data['roomId']);
        break;
      case 'family':
        Get.toNamed('/family');
        break;
      case 'event':
        Get.toNamed('/event-listing');
        break;
      default:
        debugPrint('Unknown notification type: $type');
    }
  }

  Future<void> _syncFCMTokenToBackend(String token) async {
    try {
      await _apiService.post(
        '/auth/fcm-token',
        body: {'fcmToken': token},
      );
      debugPrint('✅ FCM token synced to backend');
    } catch (e) {
      debugPrint('⚠️ Error syncing FCM token: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // AUTHENTICATION
  // ─────────────────────────────────────────────────────────────────────────

  Future<UserCredential?> signUpWithEmail(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Signup error: ${e.message}');
      rethrow;
    }
  }

  Future<UserCredential?> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Login error: ${e.message}');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      currentUser.value = null;
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('✅ Password reset email sent');
    } catch (e) {
      debugPrint('❌ Error sending password reset: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PHONE AUTH (Updated for exact integration)
  // ─────────────────────────────────────────────────────────────────────────

  // 1. To send OTP to a mobile number (using a callback to send verificationId forward)
  Future<void> verifyPhoneNumber(
    String phoneNumber, {
    required Function(String verificationId) onCodeSent,
    required Function(FirebaseAuthException e) onVerificationFailed,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // कुछ Android फ़ोन्स में OTP अपने आप वेरिफाई हो जाता है
          // On some Android devices, OTP is auto-verified
          await _auth.signInWithCredential(credential);
          debugPrint('✅ Phone auto-verification completed and signed in');
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('❌ Phone verification failed: ${e.message}');
          onVerificationFailed(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('✅ OTP sent successfully. ID: $verificationId');
          // UI को verificationId पास करें ताकि वह OTP स्क्रीन पर जा सके
          // Pass verificationId to the UI so it can navigate to the OTP screen
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('⚠️ Code auto-retrieval timeout');
          // You can handle timeout logic here if needed
        },
      );
    } on FirebaseAuthException catch (e) {
      onVerificationFailed(e);
    }
  }

  // 2. जब यूज़र स्क्रीन पर OTP डाल दे, तब इस मेथड को कॉल करके लॉगिन पूरा करें
  Future<UserCredential?> signInWithOTP(
    String verificationId,
    String smsCode,
  ) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('❌ Phone sign in error (Invalid OTP): $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GETTERS
  // ─────────────────────────────────────────────────────────────────────────

  User? get user => _auth.currentUser;
  String get userId => _auth.currentUser?.uid ?? '';
  String? get userEmail => _auth.currentUser?.email;
  String? get userPhone => _auth.currentUser?.phoneNumber;
  bool get isLoggedIn => _auth.currentUser != null;
}