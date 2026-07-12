// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/auth/presentation/controllers/auth_controller.dart
// ARVIND PARTY - AUTH CONTROLLER (Phone OTP Auth with Node.js Backend)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../../core/services/auth_session_manager.dart';
import '../../models/auth_model.dart';
import '../repositories/auth_repository.dart';

class AuthController extends GetxController {
  final authRepository = AuthRepository();
  final AuthSessionManager _session = Get.find<AuthSessionManager>();

  var isLoggedIn = false.obs;
  var currentUser = Rxn<User>();
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var token = ''.obs;
  var phoneNumber = ''.obs;
  var otpSent = false.obs;
  var isNewUser = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    final savedToken = _session.token.value;
    if (savedToken != null && savedToken.isNotEmpty) {
      token.value = savedToken;
      isLoggedIn.value = true;
      await fetchCurrentUser();
    }
  }

  Future<bool> sendOtp(String phone) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await authRepository.sendOtp(phone);
      if (response['success'] == true) {
        phoneNumber.value = phone;
        otpSent.value = true;
        isLoading.value = false;
        return true;
      } else {
        errorMessage.value = response['message'] ?? 'Failed to send OTP';
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
      return false;
    }
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await authRepository.verifyOtp(phone: phone, otp: otp);
      if (response.success) {
        token.value = response.token;
        currentUser.value = response.user;
        isLoggedIn.value = true;
        isNewUser.value = response.isNewUser;
        await _session.saveSession(
          token: response.token,
          userId: response.user.id,
          userName: response.user.username,
          userEmail: response.user.email,
          userAvatar: response.user.profileImage ?? '',
          userPhone: phone,
        );
        isLoading.value = false;
        return true;
      } else {
        errorMessage.value = response.message;
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
      return false;
    }
  }

  Future<bool> resendOtp(String phone) async {
    isLoading.value = true;
    try {
      final response = await authRepository.resendOtp(phone);
      isLoading.value = false;
      return response['success'] == true;
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
      return false;
    }
  }

  Future<bool> register({required String phone, required String name, String? gender, DateTime? dob}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await authRepository.register(phone: phone, name: name, gender: gender, dob: dob);
      if (response.success) {
        token.value = response.token;
        currentUser.value = response.user;
        isLoggedIn.value = true;
        await _session.saveSession(
          token: response.token,
          userId: response.user.id,
          userName: response.user.username,
          userEmail: response.user.email,
          userAvatar: response.user.profileImage ?? '',
          userPhone: phone,
        );
        isLoading.value = false;
        return true;
      } else {
        errorMessage.value = response.message;
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
      return false;
    }
  }

  Future<bool> emailLogin({required String email, required String password}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      Get.snackbar('Info', 'Please use phone login for mobile app');
      isLoading.value = false;
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      isLoading.value = false;
      return false;
    }
  }

  void logout() async {
    isLoading.value = true;
    try {
      await authRepository.logout();
    } catch (e) {
      debugPrint('Error during token validation: $e');
    } finally {
      isLoggedIn.value = false;
    }
    currentUser.value = null;
    token.value = '';
    phoneNumber.value = '';
    otpSent.value = false;
    isNewUser.value = false;
    await _session.clearSession();
    isLoading.value = false;
    Get.offAllNamed('/login');
  }

  Future<void> fetchCurrentUser() async {
    try {
      final user = await authRepository.getCurrentUser();
      currentUser.value = user;
      isLoggedIn.value = true;
    } catch (e) {
      final savedRefreshToken = _session.refreshToken.value;
      if (savedRefreshToken != null && savedRefreshToken.isNotEmpty) {
        try {
          final newToken = await authRepository.refreshToken(savedRefreshToken);
          token.value = newToken;
          await _session.saveSession(token: newToken);
          final user = await authRepository.getCurrentUser();
          currentUser.value = user;
          return;
        } catch (e) {
          debugPrint('Auth error: $e');
        }
      }
      isLoggedIn.value = false;
      currentUser.value = null;
      token.value = '';
      await _session.clearSession();
      Get.offAllNamed('/login');
    }
  }

  String getAuthToken() => _session.token.value ?? token.value;
  String getUserId() => _session.userId.value ?? currentUser.value?.id ?? '';
}
