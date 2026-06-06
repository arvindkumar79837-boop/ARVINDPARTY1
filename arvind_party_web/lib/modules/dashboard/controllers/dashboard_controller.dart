import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../../core/constants/api_constants.dart';

class DashboardController extends GetxController {
  var isLoading = true.obs;
  var totalUsers = 0.obs;
  var activeRooms = 0.obs;
  var totalRevenue = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStats();
  }

  Future<void> fetchStats() async {
    try {
      isLoading.value = true;
      final token = GetStorage().read('staff_token');

      final response = await http.get(
        Uri.parse('${ApiConstants.apiBaseUrl}/admin/stats'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        totalUsers.value = data['data']['totalUsers'] ?? 0;
        activeRooms.value = data['data']['activeRooms'] ?? 0;
        totalRevenue.value = data['data']['totalRevenue'] ?? 0;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load dashboard stats',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
