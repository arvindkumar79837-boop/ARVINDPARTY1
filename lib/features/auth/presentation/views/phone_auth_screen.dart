// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/auth/presentation/views/phone_auth_screen.dart
// ARVIND PARTY - PHONE AUTH SCREEN (FIXED with GetX Integration)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart'; // Import AuthController

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final phoneController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  // Get the instance of AuthController
  final AuthController authController = Get.find<AuthController>();

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  // Updated function to handle phone submission with the controller
  void _submitPhone() async {
    if (formKey.currentState!.validate()) {
      // Assuming a default country code for simplicity. 
      // In a real app, use a country code picker.
      final fullPhoneNumber = '+91${phoneController.text}';

      // Call the sendOtp method from the controller
      final success = await authController.sendOtp(fullPhoneNumber);

      if (success) {
        // Navigate to OTP screen only on success
        Get.toNamed('/otp-screen');
        Get.snackbar(
          'Success',
          'OTP sent to $fullPhoneNumber',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // Show an error snackbar if OTP sending fails
        Get.snackbar(
          'Error',
          authController.errorMessage.value,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(
                Icons.phone_android,
                color: Color(0xFFFFC107),
                size: 64,
              ),
              const SizedBox(height: 24),
              const Text(
                'Phone Authentication',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Enter your phone number to receive a verification code',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '9876543210',
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.phone, color: Colors.white70),
                  prefixText: '+91 ',
                  prefixStyle: const TextStyle(color: Colors.white, fontSize: 18),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFFC107)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.redAccent),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.redAccent),
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 12/255),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Phone number is required';
                  }
                  if (value!.length < 10) {
                    return 'Enter a valid 10-digit phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                // Use Obx to make the UI reactive to controller's state
                child: Obx(() {
                  // Show a loading indicator when isLoading is true
                  if (authController.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFFC107),
                      ),
                    );
                  }
                  // Otherwise, show the button
                  return ElevatedButton(
                    onPressed: _submitPhone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Send Verification Code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}