import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../../core/constants/api_constants.dart';

class AgencyController extends GetxController {
  var isLoading = true.obs;
  var agencies = <dynamic>[].obs;
  var isLoadingHosts = false.obs;
  var agencyHosts = <dynamic>[].obs;

  final agencyNameController = TextEditingController();
  final ownerUidController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadAgencies();
  }

  Future<void> loadAgencies() async {
    try {
      isLoading.value = true;
      final token = GetStorage().read('staff_token');
      final response = await http.get(
          Uri.parse('${ApiConstants.apiBaseUrl}/admin/agencies'),
          headers: {'Authorization': 'Bearer $token'});
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        agencies.assignAll(data['data'] ?? []);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAgencyHosts(String agencyId) async {
    try {
      isLoadingHosts.value = true;
      agencyHosts.clear();
      final token = GetStorage().read('staff_token');
      final response = await http.get(
        Uri.parse('${ApiConstants.apiBaseUrl}/admin/agencies/$agencyId/hosts'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        agencyHosts.assignAll(data['data'] ?? []);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load hosts',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoadingHosts.value = false;
    }
  }

  Future<void> createAgency() async {
    final name = agencyNameController.text.trim();
    final uid = ownerUidController.text.trim();
    if (name.isEmpty || uid.isEmpty) {
      Get.snackbar('Error', 'Please fill both fields',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    try {
      final token = GetStorage().read('staff_token');
      final response = await http.post(
        Uri.parse('${ApiConstants.apiBaseUrl}/admin/agencies'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({'name': name, 'ownerUid': uid}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        Get.back(); // Close Dialog
        Get.snackbar('Success', 'Agency created successfully',
            backgroundColor: Colors.green, colorText: Colors.white);
        agencyNameController.clear();
        ownerUidController.clear();
        loadAgencies(); // Refresh List
      } else {
        Get.snackbar('Error', data['message'] ?? 'Creation failed',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Network error',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}
