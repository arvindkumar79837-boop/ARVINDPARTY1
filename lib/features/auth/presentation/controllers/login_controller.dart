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
      // In production, use google_sign_in package:
      // final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      // final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      // final idToken = googleAuth.idToken;

      // Placeholder for now - replace with actual Google Sign-In
      await Future.delayed(const Duration(seconds: 1));
      final providerUid = 'google_${DateTime.now().millisecondsSinceEpoch}';
      const email = 'user.google@example.com';
      const displayName = 'Google User';

      loadingMessage.value = 'Authenticating with backend...';
      await Future.delayed(const Duration(milliseconds: 800));

      final response = await authRepository.socialLogin(
        provider: 'google',
        providerUid: providerUid,
        email: email,
        displayName: displayName,
        photoUrl: googleProfilePicture.value.isEmpty ? null : googleProfilePicture.value,
      );

      Get.snackbar(
        'Success',
        'Google login successful!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );

      Get.offAllNamed('/home');
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
      // In production, use sign_in_with_apple package:
      // final credential = await SignInWithApple.getAppleIDCredential(scopes: [Scope.email, Scope.fullName]);
      // final identityToken = credential.identityToken;

      await Future.delayed(const Duration(seconds: 1));
      final providerUid = 'apple_${DateTime.now().millisecondsSinceEpoch}';
      final email = appleEmail.value.isEmpty ? 'user.apple@privaterelay.appleid.com' : appleEmail.value;
      final displayName = appleFullName.value.isEmpty ? 'Apple User' : appleFullName.value;

      loadingMessage.value = 'Authenticating with backend...';
      await Future.delayed(const Duration(milliseconds: 800));

      final response = await authRepository.socialLogin(
        provider: 'apple',
        providerUid: providerUid,
        email: email,
        displayName: displayName,
      );

      Get.snackbar(
        'Success',
        'Apple login successful!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );

      Get.offAllNamed('/home');
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
      // In production, use flutter_facebook_app_events or facebook_app_events package:
      // final LoginResult result = await FacebookAuth.instance.login();
      // final AccessToken accessToken = result.accessToken;

      await Future.delayed(const Duration(seconds: 1));
      final providerUid = 'facebook_${DateTime.now().millisecondsSinceEpoch}';
      const email = 'user.facebook@example.com';
      const displayName = 'Facebook User';

      loadingMessage.value = 'Authenticating with backend...';
      await Future.delayed(const Duration(milliseconds: 800));

      final response = await authRepository.socialLogin(
        provider: 'facebook',
        providerUid: providerUid,
        email: email,
        displayName: displayName,
      );

      Get.snackbar(
        'Success',
        'Facebook login successful!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );

      Get.offAllNamed('/home');
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
      loadingMessage.value = 'Setting up guest account...';
      await Future.delayed(const Duration(milliseconds: 800));

      final response = await authRepository.guestLogin();

      Get.snackbar(
        'Welcome',
        'Continuing as guest. Create an account to save your data!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.withValues(alpha: 0.8),
        colorText: Colors.white,
      );

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