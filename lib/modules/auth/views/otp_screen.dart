import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../controllers/phone_auth_controller.dart';

class OtpScreen extends StatelessWidget {
  // Finding the controller that was initialized in the PhoneLoginScreen
  final PhoneAuthController controller = Get.find<PhoneAuthController>();

  OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
          fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.05),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color(0xFFFFC107)),
      borderRadius: BorderRadius.circular(12),
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
            Obx(() => Text(
                  'Enter the 6-digit code sent to ${controller.currentPhone.value}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                )),
            const SizedBox(height: 40),
            
            // Real OTP Input using Pinput
            Pinput(
              length: 6,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              showCursor: true,
              onCompleted: (pin) {
                controller.verifyOtp(pin); // Trigger real verification
              },
            ),
            const SizedBox(height: 40),
            
            Obx(() => controller.isLoading.value
                ? const CircularProgressIndicator(color: Color(0xFFFFC107))
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}