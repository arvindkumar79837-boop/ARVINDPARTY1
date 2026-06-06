import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../../core/constants/api_constants.dart';

class SettingsController extends GetxController {
  var isLoading = true.obs;
  var isSaving = false.obs;

  final giftCommissionController = TextEditingController();
  final withdrawalFeeController = TextEditingController();
  final minWithdrawalController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      isLoading.value = true;
      final token = GetStorage().read('staff_token');
      final response = await http.get(
          Uri.parse('${ApiConstants.apiBaseUrl}/admin/settings'),
          headers: {'Authorization': 'Bearer $token'});
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        giftCommissionController.text =
            data['data']['giftCommission'].toString();
        withdrawalFeeController.text = data['data']['withdrawalFee'].toString();
        minWithdrawalController.text = data['data']['minWithdrawal'].toString();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveSettings() async {
    try {
      isSaving.value = true;
      final token = GetStorage().read('staff_token');
      final response = await http.post(
        Uri.parse('${ApiConstants.apiBaseUrl}/admin/settings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'giftCommission': int.tryParse(giftCommissionController.text) ?? 30,
          'withdrawalFee': int.tryParse(withdrawalFeeController.text) ?? 5,
          'minWithdrawal': int.tryParse(minWithdrawalController.text) ?? 100,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        Get.snackbar('Success', 'Global settings updated!',
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar('Error', data['message'] ?? 'Failed to update',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } finally {
      isSaving.value = false;
    }
  }
}
