import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/network/api_client.dart';

class FamilyController extends GetxController {
  final familyNameController = TextEditingController();
  final joinFamilyIdController = TextEditingController();

  var isLoading = false.obs;
  var currentFamilyId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Load existing family if available in local storage
    currentFamilyId.value = GetStorage().read('family_id') ?? '';
  }

  Future<void> createFamily() async {
    final name = familyNameController.text.trim();
    if (name.isEmpty) return;

    isLoading.value = true;
    try {
      final userId = GetStorage().read('user_id');
      final data = await ApiClient().post('/family/create', {
        'userId': userId,
        'name': name,
        'avatar':
            'https://via.placeholder.com/150', // Replace with real asset later
      });

      if (data['success'] == true) {
        Get.snackbar('Success', 'Family created successfully!',
            backgroundColor: Colors.green, colorText: Colors.white);
        currentFamilyId.value = data['data']['familyId'];
        GetStorage().write('family_id', currentFamilyId.value);
        familyNameController.clear();
      } else {
        Get.snackbar('Error', data['message'] ?? 'Failed to create family',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> joinFamily() async {
    final familyId = joinFamilyIdController.text.trim();
    if (familyId.isEmpty) return;

    isLoading.value = true;
    try {
      final userId = GetStorage().read('user_id');
      final data = await ApiClient().post('/family/join', {
        'userId': userId,
        'familyId': familyId,
      });

      if (data['success'] == true) {
        Get.snackbar('Success', 'Joined family successfully!',
            backgroundColor: Colors.green, colorText: Colors.white);
        currentFamilyId.value = familyId;
        GetStorage().write('family_id', currentFamilyId.value);
        joinFamilyIdController.clear();
      } else {
        Get.snackbar('Error', data['message'] ?? 'Failed to join family',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> leaveFamily() async {
    isLoading.value = true;
    try {
      final userId = GetStorage().read('user_id');
      final data = await ApiClient().post('/family/leave', {
        'userId': userId,
      });

      if (data['success'] == true) {
        Get.snackbar('Success', 'You have left the family.',
            backgroundColor: Colors.green, colorText: Colors.white);
        currentFamilyId.value = '';
        GetStorage().remove('family_id');
      } else {
        Get.snackbar('Error', data['message'] ?? 'Failed to leave family',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } finally {
      isLoading.value = false;
    }
  }
}
