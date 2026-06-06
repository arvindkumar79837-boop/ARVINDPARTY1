import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../../core/constants/api_constants.dart';

class UsersController extends GetxController {
  var isLoading = true.obs;
  var users = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      isLoading.value = true;
      final token = GetStorage().read('staff_token');

      final response = await http.get(
        Uri.parse('${ApiConstants.apiBaseUrl}/admin/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        users.assignAll(data['data'] ?? []);
      } else {
        Get.snackbar(
          'Error',
          data['message'] ?? 'Failed to load users',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Network Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> blockUser(String id) async {
    await _toggleBlockStatus(id);
  }

  Future<void> unblockUser(String id) async {
    await _toggleBlockStatus(id);
  }

  Future<void> _toggleBlockStatus(String id) async {
    try {
      final token = GetStorage().read('staff_token');
      final response = await http.post(
        Uri.parse('${ApiConstants.apiBaseUrl}/admin/users/block/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // List ko locally update karo jisse UI instantly change ho jaye
        final index = users.indexWhere((u) => (u['_id'] ?? u['id']) == id);
        if (index != -1) {
          final user = Map<String, dynamic>.from(users[index]);
          user['isBlocked'] = data['isBlocked'];
          users[index] = user; // Triggers UI reactivity
        }

        Get.snackbar(
          'Success',
          data['message'] ?? 'Status updated',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          data['message'] ?? 'Failed to update user',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Network Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}
