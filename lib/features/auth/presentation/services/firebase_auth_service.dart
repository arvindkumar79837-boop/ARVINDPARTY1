// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/auth/presentation/services/firebase_auth_service.dart
// ARVIND PARTY - FIREBASE AUTH SERVICE (Multi-Platform: Phone/Google/Apple)
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:io';

import 'package:arvind_party/core/services/api_service.dart';
import 'package:arvind_party/core/services/auth_session_manager.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService extends GetxService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final ApiService _apiService = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();

  var isFirebaseInitialized = false.obs;
  var currentFirebaseUser = Rxn<User>();
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      await _firebaseAuth.authStateChanges().first;
      currentFirebaseUser.value = _firebaseAuth.currentUser;
      isFirebaseInitialized.value = true;
    } catch (e) {
      errorMessage.value = 'Firebase initialization failed: $e';
    }
  }

  Future<Map<String, dynamic>?> getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'deviceId': androidInfo.serialNumber ?? androidInfo.id,
          'deviceModel': androidInfo.model,
          'deviceBrand': androidInfo.brand,
          'deviceOS': 'Android ${androidInfo.version.release}',
          'platform': 'android',
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'deviceId': iosInfo.identifierForVendor,
          'deviceModel': iosInfo.model,
          'deviceBrand': 'Apple',
          'deviceOS': 'iOS ${iosInfo.systemVersion}',
          'platform': 'ios',
        };
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        return {
          'deviceId': windowsInfo.deviceId,
          'deviceModel': windowsInfo.productName,
          'deviceBrand': windowsInfo.computerName,
          'deviceOS': 'Windows',
          'platform': 'windows',
        };
      }
    } catch (e) {
      // Device info retrieval may fail on unsupported platforms
    }
    return null;
  }

  Future<String?> signInWithPhone(String phoneNumber) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final verificationCompleter = Completer<String?>();
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          errorMessage.value = e.message ?? 'Phone verification failed';
          isLoading.value = false;
          if (!verificationCompleter.isCompleted) {
            verificationCompleter.complete(null);
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          isLoading.value = false;
          if (!verificationCompleter.isCompleted) {
            verificationCompleter.complete(verificationId);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (!verificationCompleter.isCompleted) {
            verificationCompleter.complete(verificationId);
          }
        },
      );
      return await verificationCompleter.future;
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
      return null;
    }
  }

  Future<void> _signInWithCredential(AuthCredential credential) async {
    try {
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      currentFirebaseUser.value = userCredential.user;
      await _completeFirebaseLogin(userCredential.user);
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isLoading.value = false;
        return null;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      currentFirebaseUser.value = userCredential.user;
      isLoading.value = false;

      return await _completeFirebaseLogin(userCredential.user);
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
      return null;
    }
  }

  Future<Map<String, dynamic>?> signInWithApple() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final appleSignIn = await _firebaseAuth.signInWithProvider(OAuthProvider('apple.com'));
      currentFirebaseUser.value = appleSignIn.user;
      isLoading.value = false;

      return await _completeFirebaseLogin(appleSignIn.user);
    } catch (e) {
      errorMessage.value = 'Apple Sign-In error: $e';
      isLoading.value = false;
      return null;
    }
  }

  Future<Map<String, dynamic>?> _completeFirebaseLogin(User? firebaseUser) async {
    if (firebaseUser == null) {
      isLoading.value = false;
      return null;
    }

    try {
      String? idToken;
      try {
        idToken = await firebaseUser.getIdToken();
      } catch (e) {
        errorMessage.value = 'Failed to get ID token: $e';
        isLoading.value = false;
        return null;
      }

      if (idToken == null) {
        isLoading.value = false;
        return null;
      }

      final deviceInfo = await getDeviceInfo();

      final response = await _apiService.post('/api/auth/firebase-verify', body: {
        'idToken': idToken,
        'deviceId': deviceInfo?['deviceId'],
        'deviceInfo': deviceInfo,
        'platform': deviceInfo?['platform'] ?? 'mobile',
      });

      if (response['success'] == true) {
        final data = response['data'];
        final token = data['token'] as String;
        final refreshToken = data['refreshToken'] as String;
        final user = data['user'] as Map<String, dynamic>;

        _apiService.saveToken(token);
        _storage.write('refreshToken', refreshToken);
        _storage.write('firebaseUid', firebaseUser.uid);
        _storage.write('isLoggedIn', true);

        currentFirebaseUser.value = firebaseUser;
        isLoading.value = false;

        return {
          'success': true,
          'token': token,
          'refreshToken': refreshToken,
          'user': user,
          'isNewUser': user['isNewUser'] ?? false,
        };
      } else {
        errorMessage.value = response['message'] ?? 'Firebase login failed';
        isLoading.value = false;
        return null;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
      return null;
    }
  }

  Future<void> verifyOtpAndLogin(String verificationId, String otp) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      currentFirebaseUser.value = userCredential.user;

      await _completeFirebaseLogin(userCredential.user);
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      _apiService.clearToken();
      _storage.remove('refreshToken');
      _storage.remove('firebaseUid');
      _storage.remove('isLoggedIn');
      currentFirebaseUser.value = null;
      isFirebaseInitialized.value = false;
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await _apiService.get('/api/auth/me');
      if (response['success'] == true) {
        return response['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getSavedRefreshToken() async {
    return _storage.read<String>('refreshToken');
  }
}