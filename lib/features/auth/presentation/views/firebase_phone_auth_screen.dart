// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/auth/presentation/views/firebase_phone_auth_screen.dart
// ARVIND PARTY - FIREBASE PHONE AUTH SCREEN (OTP via Firebase)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../../../home/presentation/views/home_screen.dart';
import '../services/firebase_auth_service.dart';

class FirebasePhoneAuthScreen extends StatefulWidget {
  const FirebasePhoneAuthScreen({super.key});

  @override
  State<FirebasePhoneAuthScreen> createState() => _FirebasePhoneAuthScreenState();
}

class _FirebasePhoneAuthScreenState extends State<FirebasePhoneAuthScreen> {
  final FirebaseAuthService _firebaseAuthService = Get.find<FirebaseAuthService>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _verificationId;
  bool _isOtpSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final phone = '+91${_phoneController.text.trim()}';
    final verificationId = await _firebaseAuthService.signInWithPhone(phone);

    if (verificationId != null) {
      setState(() {
        _verificationId = verificationId;
        _isOtpSent = true;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      Get.snackbar(
        'Error',
        _firebaseAuthService.errorMessage.value.isNotEmpty
            ? _firebaseAuthService.errorMessage.value
            : 'Failed to send OTP',
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().length < 6) {
      Get.snackbar(
        'Error',
        'Please enter the complete 6-digit OTP',
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isLoading = true);

    await _firebaseAuthService.verifyOtpAndLogin(
      _verificationId!,
      _otpController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (_firebaseAuthService.currentFirebaseUser.value != null) {
      Get.offAll(() => const HomeScreen());
    } else {
      Get.snackbar(
        'Error',
        _firebaseAuthService.errorMessage.value.isNotEmpty
            ? _firebaseAuthService.errorMessage.value
            : 'OTP verification failed',
        backgroundColor: Colors.red.shade900,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        title: const Text('Phone Login', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF15141F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8906).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.phone_android,
                    size: 40,
                    color: Color(0xFFFF8906),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Enter your mobile number',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You will receive a 6-digit OTP via SMS',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              const SizedBox(height: 32),

              if (!_isOtpSent) ...[
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[800]!),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text(
                        '+91',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 24,
                        width: 1,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          maxLength: 10,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Phone number is required';
                            }
                            if (value.trim().length != 10) {
                              return 'Enter a valid 10-digit phone number';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter mobile number',
                            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                            border: InputBorder.none,
                            counterText: '',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8906),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      disabledBackgroundColor: Colors.grey[700],
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Send OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],

              if (_isOtpSent) ...[
                const Text(
                  'Enter OTP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Pinput(
                    controller: _otpController,
                    length: 6,
                    defaultPinTheme: PinTheme(
                      width: 50,
                      height: 55,
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[700]!),
                      ),
                    ),
                    focusedPinTheme: PinTheme(
                      width: 50,
                      height: 55,
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFF8906), width: 2),
                      ),
                    ),
                    submittedPinTheme: PinTheme(
                      width: 50,
                      height: 55,
                      textStyle: const TextStyle(
                        color: Color(0xFFFF8906),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFF8906)),
                      ),
                    ),
                    onCompleted: (pin) {
                      _verifyOtp();
                    },
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8906),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      disabledBackgroundColor: Colors.grey[700],
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Verify & Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isOtpSent = false;
                        _otpController.clear();
                      });
                    },
                    child: const Text(
                      'Change phone number',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}