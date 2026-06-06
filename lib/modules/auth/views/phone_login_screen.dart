import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../controllers/phone_auth_controller.dart';

class PhoneLoginScreen extends StatelessWidget {
  final PhoneAuthController controller = Get.put(PhoneAuthController());
  final RxString fullPhoneNumber = ''.obs;

  PhoneLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Phone Login', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your phone number',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'We will send you an OTP to verify your account.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 32),

            // Real International Phone Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: InternationalPhoneNumberInput(
                onInputChanged: (PhoneNumber number) {
                  fullPhoneNumber.value = number.phoneNumber ?? '';
                },
                selectorConfig: const SelectorConfig(
                  selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                  useEmoji: true,
                ),
                textStyle: const TextStyle(color: Colors.white),
                cursorColor: const Color(0xFFFFC107),
                inputDecoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Phone Number',
                  hintStyle: TextStyle(color: Colors.white54),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Send OTP Button
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            if (fullPhoneNumber.value.isNotEmpty) {
                              controller.sendOtp(fullPhoneNumber.value);
                            } else {
                              Get.snackbar(
                                  'Error', 'Please enter a valid phone number');
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            'Send OTP',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
