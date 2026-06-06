import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth/views/api_service.dart';
import '../../home/controllers/home_controller.dart';

class CreateRoomController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController nameController = TextEditingController();
  var isLoading = false.obs;
  var coverBase64 = ''.obs;
  var selectedImagePath = ''.obs;

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 60);
      if (image != null) {
        selectedImagePath.value = image.path;
        final bytes = await File(image.path).readAsBytes();
        coverBase64.value = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image');
    }
  }

  Future<void> createRoom() async {
    String name = nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Required', 'Please enter a room name');
      return;
    }

    isLoading(true);
    try {
      var response = await _apiService.post('rooms/create', {
        'name': name,
        'coverImage': coverBase64.value,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.snackbar('Success', 'Room created successfully!');
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().fetchLiveRooms(); // Instantly refresh Discovery Feed
        }
        Get.back(); // Return to Home Screen
      } else {
        Get.snackbar('Error', 'Could not create room');
      }
    } catch (e) {
      Get.snackbar('Server Error', 'Failed to connect to Arvind Party servers.');
    } finally {
      isLoading(false);
    }
  }
}