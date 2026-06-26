// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/auth/presentation/views/otp_screen.dart
// ARVIND PARTY - OTP SCREEN (FIXED with GetX Integration)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../controllers/auth_controller.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // Get the instance of AuthController
  final AuthController authController = Get.find<AuthController>();
  final pinController = TextEditingController();
  final focusNode = FocusNode();

  // Updated function to handle OTP verification with the controller
  void _verifyOtp(String pin) async {
    // The phone number is already stored in the controller from the previous screen
    final String phoneNumber = authController.phoneNumber.value;

    if (phoneNumber.isEmpty) {
      Get.snackbar(
        'Error',
        'Phone number not found. Please go back and try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Call the verifyOtp method from the controller
    final bool success = await authController.verifyOtp(phoneNumber, pin);

    if (success) {
      // On success, navigate to the home screen, clearing the auth stack
      Get.offAllNamed('/home');
      Get.snackbar(
        'Welcome!',
        'Successfully logged in.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      // Show an error snackbar if OTP verification fails
      Get.snackbar(
        'Verification Failed',
        authController.errorMessage.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Function to handle resending OTP
  void _resendOtp() async {
    final String phoneNumber = authController.phoneNumber.value;
    final bool success = await authController.resendOtp(phoneNumber);
    if (success) {
      Get.snackbar(
        'Success',
        'A new OTP has been sent to $phoneNumber',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed to resend OTP. Please wait before trying again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.white,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
        color: Colors.white.withAlpha(12),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Verification Code',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Use Obx to reactively display the phone number from the controller
            Obx(() => Text(
                  'Enter the 6-digit code sent to ${authController.phoneNumber.value}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                )),
            const SizedBox(height: 40),

            // Use Obx to show a loading indicator or the Pinput field
            Obx(() {
              if (authController.isLoading.value) {
                return const CircularProgressIndicator(color: Color(0xFFFFC107));
              }
              return Pinput(
                length: 6,
                controller: pinController,
                focusNode: focusNode,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(color: const Color(0xFFFFC107)),
                  ),
                ),
                submittedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    color: Colors.white.withAlpha(20),
                  ),
                ),
                showCursor: true,
                onCompleted: (pin) {
                  // Trigger OTP verification when the user completes entering the pin
                  _verifyOtp(pin);
                },
              );
            }),
            const SizedBox(height: 40),
            RichText(
              text: TextSpan(
                text: "Didn't receive the code? ",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                children: [
                  TextSpan(
                    text: 'Resend',
                    style: const TextStyle(
                      color: Color(0xFFFFC107),
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = _resendOtp,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}