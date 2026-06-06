import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/complete_profile_controller.dart';

class CompleteProfileScreen extends StatelessWidget {
  final CompleteProfileController controller =
      Get.put(CompleteProfileController());

  CompleteProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Complete Profile',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Set up your Arvind Party Identity',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 40),

            // Avatar Picker
            GestureDetector(
              onTap: controller.pickImage,
              child: Obx(() {
                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                    border:
                        Border.all(color: const Color(0xFFFFC107), width: 2),
                    image: controller.selectedImagePath.value.isNotEmpty
                        ? DecorationImage(
                            image: FileImage(
                                File(controller.selectedImagePath.value)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: controller.selectedImagePath.value.isEmpty
                      ? const Icon(Icons.camera_alt,
                          color: Color(0xFFFFC107), size: 40)
                      : null,
                );
              }),
            ),
            const SizedBox(height: 12),
            const Text('Upload Avatar',
                style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 40),

            // Name Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: TextField(
                controller: controller.nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter your Nickname',
                  hintStyle: TextStyle(color: Colors.white54),
                  icon: Icon(Icons.person, color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(height: 60),

            // Submit Button
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.submitProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text('Start Partying!',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
