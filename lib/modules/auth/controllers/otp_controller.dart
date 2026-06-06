// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/modules/auth/controllers/otp_controller.dart
//
// PHONE OTP AUTH CONTROLLER
// Flow: Phone Number Enter → OTP Send → OTP Verify → New User? → Profile Setup
//                                                  → Old User?  → Home
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../auth/views/api_service.dart';
import '../../../routes/app_routes.dart';

// OTP Screen States
enum OtpScreenState { phoneInput, otpInput, profileSetup }

class OtpController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  // ─── SCREEN STATE ─────────────────────────────────────────────────────────
  final screenState = OtpScreenState.phoneInput.obs;

  // ─── PHONE INPUT ──────────────────────────────────────────────────────────
  final phoneNumber = ''.obs; // only digits e.g. 9876543210
  final countryCode = '+91'.obs; // default India
  final countryFlag = '🇮🇳'.obs;
  final isPhoneValid = false.obs;

  // ─── OTP ──────────────────────────────────────────────────────────────────
  final otpCode = ''.obs; // 6 digit OTP
  final isOtpSent = false.obs;
  final isOtpVerified = false.obs;

  // ─── RESEND TIMER ─────────────────────────────────────────────────────────
  final resendSeconds = 0.obs;
  Timer? _resendTimer;
  static const int _resendCooldown = 60;

  // ─── PROFILE SETUP ────────────────────────────────────────────────────────
  final displayName = ''.obs;
  final selectedGender = ''.obs; // male / female / other
  final selectedDob = Rxn<DateTime>();
  final isNewUser = true.obs;

  // ─── LOADING ──────────────────────────────────────────────────────────────
  final isLoading = false.obs;
  final loadingMsg = ''.obs;
  final errorMsg = ''.obs;

  final _storage = GetStorage();

  // ─── POPULAR COUNTRY CODES ────────────────────────────────────────────────
  final countryCodes = const [
    {'flag': '🇮🇳', 'name': 'India', 'code': '+91', 'maxLen': 10},
    {'flag': '🇺🇸', 'name': 'United States', 'code': '+1', 'maxLen': 10},
    {'flag': '🇬🇧', 'name': 'United Kingdom', 'code': '+44', 'maxLen': 10},
    {'flag': '🇦🇪', 'name': 'UAE', 'code': '+971', 'maxLen': 9},
    {'flag': '🇸🇦', 'name': 'Saudi Arabia', 'code': '+966', 'maxLen': 9},
    {'flag': '🇵🇰', 'name': 'Pakistan', 'code': '+92', 'maxLen': 10},
    {'flag': '🇧🇩', 'name': 'Bangladesh', 'code': '+880', 'maxLen': 10},
    {'flag': '🇳🇬', 'name': 'Nigeria', 'code': '+234', 'maxLen': 10},
    {'flag': '🇧🇷', 'name': 'Brazil', 'code': '+55', 'maxLen': 11},
    {'flag': '🇮🇩', 'name': 'Indonesia', 'code': '+62', 'maxLen': 11},
    {'flag': '🇲🇾', 'name': 'Malaysia', 'code': '+60', 'maxLen': 10},
    {'flag': '🇵🇭', 'name': 'Philippines', 'code': '+63', 'maxLen': 10},
    {'flag': '🇹🇷', 'name': 'Turkey', 'code': '+90', 'maxLen': 10},
    {'flag': '🇪🇬', 'name': 'Egypt', 'code': '+20', 'maxLen': 10},
    {'flag': '🇿🇦', 'name': 'South Africa', 'code': '+27', 'maxLen': 9},
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // PHONE VALIDATION
  // ─────────────────────────────────────────────────────────────────────────

  void onPhoneChanged(String value) {
    phoneNumber.value = value.replaceAll(RegExp(r'\D'), '');
    errorMsg.value = '';

    // Get max length for selected country
    final maxLen = _getMaxLen();
    isPhoneValid.value = phoneNumber.value.length == maxLen;
  }

  int _getMaxLen() {
    final match =
        countryCodes.firstWhereOrNull((c) => c['code'] == countryCode.value);
    return match?['maxLen'] as int? ?? 10;
  }

  void selectCountry(Map<String, dynamic> country) {
    countryCode.value = country['code'] as String;
    countryFlag.value = country['flag'] as String;
    phoneNumber.value = '';
    isPhoneValid.value = false;
    Get.back();
  }

  String get fullPhone => '${countryCode.value}${phoneNumber.value}';

  // ─────────────────────────────────────────────────────────────────────────
  // SEND OTP
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> sendOtp() async {
    if (!isPhoneValid.value) {
      errorMsg.value = 'Please enter a valid phone number';
      return;
    }

    try {
      _setLoading('Sending OTP...');

      final res = await _apiService.post('auth/send-otp', {'phone': fullPhone});

      if (res.statusCode == 200) {
        _clearLoading();
        _transitionToOtpInput();
      } else {
        _setError(res.data['message'] ?? 'Failed to send OTP.');
      }
    } catch (e) {
      _setError('Failed to send OTP. Try again.');
    }
  }

  void _transitionToOtpInput() {
    isOtpSent.value = true;
    screenState.value = OtpScreenState.otpInput;
    _startResendTimer();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // VERIFY OTP
  // ─────────────────────────────────────────────────────────────────────────

  void onOtpChanged(String value) {
    otpCode.value = value;
    errorMsg.value = '';
    if (value.length == 6) verifyOtp();
  }

  Future<void> verifyOtp() async {
    if (otpCode.value.length != 6) {
      errorMsg.value = 'Enter complete 6-digit OTP';
      return;
    }

    try {
      _setLoading('Verifying OTP...');

      final res = await _apiService
          .post('auth/verify-otp', {'phone': fullPhone, 'otp': otpCode.value});

      if (res.statusCode == 200) {
        isNewUser.value = res.data['isNewUser'] ?? false;
        _storage.write('token', res.data['token']);
        _apiService.saveToken(res.data['token']); // Persist in Dio

        isOtpVerified.value = true;
        _clearLoading();
        _stopResendTimer();

        if (isNewUser.value) {
          screenState.value = OtpScreenState.profileSetup;
        } else {
          _saveSessionAndGoHome();
        }
      } else {
        _setError(res.data['message'] ?? 'Incorrect OTP. Please try again.');
      }
    } catch (e) {
      _setError('Verification failed. Please try again.');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // RESEND OTP
  // ─────────────────────────────────────────────────────────────────────────

  void resendOtp() {
    if (resendSeconds.value > 0) return;
    otpCode.value = '';
    errorMsg.value = '';
    sendOtp();
  }

  void _startResendTimer() {
    resendSeconds.value = _resendCooldown;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (resendSeconds.value <= 0) {
        t.cancel();
      } else {
        resendSeconds.value--;
      }
    });
  }

  void _stopResendTimer() {
    _resendTimer?.cancel();
    resendSeconds.value = 0;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PROFILE SETUP (New User only)
  // ─────────────────────────────────────────────────────────────────────────

  void onNameChanged(String value) {
    displayName.value = value.trim();
    errorMsg.value = '';
  }

  void selectGender(String gender) => selectedGender.value = gender;

  void selectDob(DateTime dob) => selectedDob.value = dob;

  bool get isProfileValid =>
      displayName.value.length >= 2 && selectedGender.value.isNotEmpty;

  Future<void> completeProfileSetup() async {
    if (!isProfileValid) {
      if (displayName.value.length < 2) {
        errorMsg.value = 'Name must be at least 2 characters';
      } else {
        errorMsg.value = 'Please select your gender';
      }
      return;
    }

    try {
      _setLoading('Setting up your profile...');

      final res = await _apiService.post('users/complete-profile', {
        'name': displayName.value,
        'gender': selectedGender.value,
        'dob': selectedDob.value?.toIso8601String(),
      });

      if (res.statusCode == 200) {
        _clearLoading();
        _saveSessionAndGoHome();
      } else {
        _setError('Could not complete profile. Try again.');
      }
    } catch (e) {
      _setError('Profile setup failed. Try again.');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BACK NAVIGATION
  // ─────────────────────────────────────────────────────────────────────────

  void goBack() {
    errorMsg.value = '';
    switch (screenState.value) {
      case OtpScreenState.otpInput:
        _stopResendTimer();
        isOtpSent.value = false;
        otpCode.value = '';
        screenState.value = OtpScreenState.phoneInput;
        break;
      case OtpScreenState.profileSetup:
        // Profile setup se wapas nahi jaate — user already verified hai
        break;
      case OtpScreenState.phoneInput:
        Get.back();
        break;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SESSION
  // ─────────────────────────────────────────────────────────────────────────

  void _saveSessionAndGoHome() {
    _storage.write('is_logged_in', true);
    _storage.write('user_phone', fullPhone);
    _storage.write(
        'user_name',
        displayName.value.isNotEmpty
            ? displayName.value
            : 'User ${phoneNumber.value.substring(phoneNumber.value.length - 4)}');
    Get.offAllNamed(AppRoutes.home);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  void _setLoading(String msg) {
    loadingMsg.value = msg;
    isLoading.value = true;
    errorMsg.value = '';
  }

  void _clearLoading() {
    isLoading.value = false;
    loadingMsg.value = '';
  }

  void _setError(String msg) {
    isLoading.value = false;
    loadingMsg.value = '';
    errorMsg.value = msg;
  }

  @override
  void onClose() {
    _stopResendTimer();
    super.onClose();
  }
}
