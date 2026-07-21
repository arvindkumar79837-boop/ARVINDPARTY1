// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/auth/presentation/controllers/login_controller.dart
// ARVIND PARTY - LOGIN CONTROLLER (Social + Guest Auth)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../routes/app_routes.dart';
import '../repositories/auth_repository.dart';

class LoginController extends GetxController {
  final authRepository = AuthRepository();
  final storage = GetStorage();

  var isLoading = false.obs;
  var loadingMessage = ''.obs;
  var isTermsAccepted = false.obs;
  var errorMessage = ''.obs;

  // Social login form fields
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  final authFormKey = GlobalKey<FormState>();

  // Google login
  var googleName = ''.obs;
  var googleEmail = ''.obs;
  var googleProfilePicture = ''.obs;

  // Apple login
  var appleUserId = ''.obs;
  var appleEmail = ''.obs;
  var appleFullName = ''.obs;

  // Facebook login
  var facebookName = ''.obs;
  var facebookEmail = ''.obs;
  var facebookProfilePicture = ''.obs;

  // Guest login
  var guestDeviceId = ''.obs;
  var guestSessionExpiry = DateTime.now().add(const Duration(days: 30)).obs;

  // Password visibility toggle
  var obscurePassword = true.obs;

  // Password reset
  var resetType = 'phone'.obs;

  @override
  void onInit() {
    super.onInit();
    _generateGuestDeviceId();
  }

  void _generateGuestDeviceId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    guestDeviceId.value = 'guest_${timestamp}_$random';
  }

  void toggleTerms() {
    isTermsAccepted.value = !isTermsAccepted.value;
  }

  bool _checkTerms() {
    if (!isTermsAccepted.value) {
      Get.snackbar(
        'Terms & Conditions',
        'Please accept the Terms of Use and Privacy Policy first.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
      return false;
    }
    return true;
  }

  void goToSignup() {
    Get.toNamed(AppRoutes.signup);
  }

  void goToPhoneAuth() {
    Get.toNamed(AppRoutes.phoneAuth);
  }

  void goToEmailLogin() async {
    if (!_checkTerms()) return;
    Get.toNamed(AppRoutes.emailLogin);
  }

  void goToPasswordReset() async {
    Get.toNamed(AppRoutes.passwordReset);
  }

  // ===== GOOGLE LOGIN =====

  Future<void> loginWithGoogle() async {
    if (!_checkTerms()) return;

    isLoading.value = true;
    loadingMessage.value = 'Connecting to Google...';
    errorMessage.value = '';

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        isLoading.value = false;
        loadingMessage.value = '';
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      loadingMessage.value = 'Signing in with Firebase...';
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final idToken = await userCredential.user?.getIdToken();

      if (idToken != null) {
        loadingMessage.value = 'Authenticating with backend...';
        await authRepository.socialLogin(
          provider: 'google',
          idToken: idToken,
        );

        Get.snackbar(
          'Success',
          'Google login successful!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
        );

        Get.offAllNamed(AppRoutes.home);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Login Failed',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      loadingMessage.value = '';
    }
  }

  Future<void> loginWithApple() async {
    if (!_checkTerms()) return;

    isLoading.value = true;
    loadingMessage.value = 'Connecting to Apple...';
    errorMessage.value = '';

    try {
      final appleProvider = OAuthProvider('apple.com');
      final userCredential = await FirebaseAuth.instance.signInWithProvider(appleProvider);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        isLoading.value = false;
        loadingMessage.value = '';
        return;
      }

      final idToken = await firebaseUser.getIdToken();
      if (idToken != null) {
        loadingMessage.value = 'Authenticating with backend...';
        await authRepository.socialLogin(
          provider: 'apple',
          idToken: idToken,
        );

        Get.snackbar(
          'Success',
          'Apple login successful!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
        );

        Get.offAllNamed(AppRoutes.home);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Login Failed',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      loadingMessage.value = '';
    }
  }

  Future<void> loginWithFacebook() async {
    Get.snackbar(
      'Not Available',
      'Facebook login is not supported in this version.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.withValues(alpha: 0.8),
      colorText: Colors.white,
    );
  }

  Future<void> continueAsGuest() async {
    if (!_checkTerms()) return;

    isLoading.value = true;
    loadingMessage.value = 'Creating guest session...';
    errorMessage.value = '';

    try {
      loadingMessage.value = 'Setting up guest account...';

      await authRepository.guestLogin();

      Get.snackbar(
        'Welcome',
        'Continuing as guest. Create an account to save your data!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.withValues(alpha: 0.8),
        colorText: Colors.white,
      );

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to create guest session. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      loadingMessage.value = '';
    }
  }

  bool validateEmailLoginForm() {
    final isValid = authFormKey.currentState?.validate() ?? false;
    if (!isValid) {
      Get.snackbar(
        'Validation Error',
        'Please check your credentials',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
    return isValid;
  }

  Future<void> submitEmailLogin() async {
    if (!validateEmailLoginForm()) return;

    isLoading.value = true;
    loadingMessage.value = 'Logging in...';
    errorMessage.value = '';

    try {
      // Email login is for web admin panel
      Get.snackbar(
        'Info',
        'Email login is available on the web panel',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.8),
        colorText: Colors.white,
      );

      Get.back();
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Login Failed',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      loadingMessage.value = '';
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}