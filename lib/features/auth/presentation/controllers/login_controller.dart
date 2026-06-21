// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/auth/presentation/controllers/login_controller.dart
// ARVIND PARTY - LOGIN CONTROLLER (Social + Guest Auth)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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
    Get.toNamed('/signup');
  }

  void goToPhoneAuth() {
    Get.toNamed('/phone-auth');
  }

  void goToEmailLogin() async {
    if (!_checkTerms()) return;
    Get.toNamed('/email-login');
  }

  void goToPasswordReset() async {
    Get.toNamed('/password-reset');
  }

  // ===== GOOGLE LOGIN =====

  Future<void> loginWithGoogle() async {
    if (!_checkTerms()) return;

    isLoading.value = true;
    loadingMessage.value = 'Connecting to Google...';
    errorMessage.value = '';

    try {
      // Simulate Google Sign-In implementation
      // In production, use google_sign_in package
      await Future.delayed(const Duration(seconds: 1));

      // For demonstration, use placeholder credentials
      // In production, actual Google Sign-In would be here:
      // final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      // final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      googleName.value = 'Google User';
      googleEmail.value = 'user.google@example.com';
      googleProfilePicture.value = '';

      loadingMessage.value = 'Authenticating with backend...';
      await Future.delayed(const Duration(milliseconds: 800));

      // TODO: Replace with actual Google login call
      // final response = await authRepository.socialLogin(
      //   provider: 'google',
      //   token: googleAuth.idToken!,
      //   email: googleEmail.value,
      //   name: googleName.value,
      // );

      // For now, show success and navigate
      Get.snackbar(
        'Success',
        'Google login successful! (Implementation pending)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );

      // Navigate to home after successful login
      // Get.offAllNamed('/home');
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
      // Simulate Apple Sign-In implementation
      // In production, use sign_in_with_apple package
      await Future.delayed(const Duration(seconds: 1));

      appleUserId.value = 'apple_user_${DateTime.now().millisecondsSinceEpoch}';
      appleEmail.value = 'user.apple@privaterelay.appleid.com';
      appleFullName.value = 'Apple User';

      loadingMessage.value = 'Authenticating with backend...';
      await Future.delayed(const Duration(milliseconds: 800));

      // TODO: Replace with actual Apple login call
      // final response = await authRepository.socialLogin(
      //   provider: 'apple',
      //   token: appleCredential.identityToken!,
      //   email: appleEmail.value,
      //   name: appleFullName.value,
      // );

      Get.snackbar(
        'Success',
        'Apple login successful! (Implementation pending)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );

      // Navigate to home after successful login
      // Get.offAllNamed('/home');
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
    if (!_checkTerms()) return;

    isLoading.value = true;
    loadingMessage.value = 'Connecting to Facebook...';
    errorMessage.value = '';

    try {
      // Simulate Facebook Login implementation
      // In production, use flutter_facebook_app_events or facebook_app_events package
      await Future.delayed(const Duration(seconds: 1));

      facebookName.value = 'Facebook User';
      facebookEmail.value = 'user.facebook@example.com';
      facebookProfilePicture.value = '';

      loadingMessage.value = 'Authenticating with backend...';
      await Future.delayed(const Duration(milliseconds: 800));

      // TODO: Replace with actual Facebook login call
      // final response = await authRepository.socialLogin(
      //   provider: 'facebook',
      //   token: facebookAccessToken.token,
      //   email: facebookEmail.value,
      //   name: facebookName.value,
      // );

      Get.snackbar(
        'Success',
        'Facebook login successful! (Implementation pending)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );

      // Navigate to home after successful login
      // Get.offAllNamed('/home');
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

  Future<void> continueAsGuest() async {
    if (!_checkTerms()) return;

    isLoading.value = true;
    loadingMessage.value = 'Creating guest session...';
    errorMessage.value = '';

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Save guest session with 30-day expiry
      await storage.write('guest_session', true);
      await storage.write('guest_device_id', guestDeviceId.value);
      await storage.write('guest_session_expiry', guestSessionExpiry.value.toIso8601String());

      Get.snackbar(
        'Welcome',
        'Continuing as guest. Create an account to save your data!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.withValues(alpha: 0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Navigate to home as guest
      Get.offAllNamed('/home');
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
      final email = emailController.text.trim();
      final password = passwordController.text;

      // For mobile app, delegate to phone auth
      // Email login is primarily for web admin
      Get.snackbar(
        'Info',
        'Please use phone number login for the mobile app',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withValues(alpha: 0.8),
        colorText: Colors.white,
      );

      // Go to phone auth instead
      Get.toNamed('/phone-auth');
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