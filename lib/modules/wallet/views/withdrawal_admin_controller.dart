import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class WithdrawalAdminController extends GetxController {
  var isLoading = false.obs;
  var withdrawals = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadWithdrawals();
  }

  Future<void> loadWithdrawals() async {
    isLoading.value = true;
    try {
      final token = GetStorage().read('staff_token');
      // Update with your actual server base URL
      final response = await http.get(
        Uri.parse('http://localhost:3000/api/app-users/withdrawals/all'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          withdrawals.assignAll(data['data']);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load withdrawals: $e',
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatus(String id, String status) async {
    isLoading.value = true;
    try {
      final token = GetStorage().read('staff_token');
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/app-users/withdrawals/update/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': status,
          'adminName': GetStorage().read('admin_name') ?? 'Admin'
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        Get.snackbar('Success', 'Withdrawal marked as $status',
            backgroundColor:
                status == 'rejected' ? Colors.redAccent : Colors.green,
            colorText: Colors.white);
        loadWithdrawals(); // Refresh list after completion
      } else {
        Get.snackbar('Error', data['message'] ?? 'Failed to update status',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
