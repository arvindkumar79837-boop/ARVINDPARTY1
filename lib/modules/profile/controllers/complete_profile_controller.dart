import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth/views/api_service.dart';

class CompleteProfileController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController nameController = TextEditingController();
  var isLoading = false.obs;
  var avatarBase64 = ''.obs;
  var selectedImagePath = ''.obs;

  // Pick Avatar from Gallery
  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 50);
      if (image != null) {
        selectedImagePath.value = image.path;
        final bytes = await File(image.path).readAsBytes();
        avatarBase64.value = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image');
    }
  }

  // Send Real Data to the Arvind Party Backend
  Future<void> submitProfile() async {
    String name = nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Required', 'Please enter your name');
      return;
    }

    isLoading(true);
    try {
      var response = await _apiService.post('users/complete-profile', {
        'name': name,
        'avatar': avatarBase64.value,
      });

      if (response.statusCode == 200) {
        Get.offAllNamed('/home'); // Navigate to the Discovery Home screen!
      } else {
        Get.snackbar('Error', 'Could not update profile');
      }
    } catch (e) {
      Get.snackbar('Server Error', 'Failed to connect to servers.');
    } finally {
      isLoading(false);
    }
  }
}
