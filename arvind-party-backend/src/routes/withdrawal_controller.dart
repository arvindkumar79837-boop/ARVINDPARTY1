import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../../core/constants/api_constants.dart';

class WithdrawalController extends GetxController {
  var isLoading = true.obs;
  var withdrawals = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadWithdrawals();
  }

  Future<void> loadWithdrawals() async {
    try {
      isLoading.value = true;
      final token = GetStorage().read('staff_token');
      final response = await http.get(
        Uri.parse('${ApiConstants.apiBaseUrl}/admin/withdrawals'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        withdrawals.assignAll(data['data'] ?? []);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> processRequest(String id, String status) async {
    try {
      final token = GetStorage().read('staff_token');
      final response = await http.post(
        Uri.parse('${ApiConstants.apiBaseUrl}/admin/withdrawals/$id/process'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({'status': status}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        Get.snackbar('Success', 'Withdrawal request $status',
            backgroundColor: Colors.green, colorText: Colors.white);
        loadWithdrawals(); // Refresh List
      } else {
        Get.snackbar('Error', data['message'] ?? 'Action failed',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {}
  }
}
