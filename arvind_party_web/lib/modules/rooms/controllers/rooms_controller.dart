import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../../core/constants/api_constants.dart';

class RoomsController extends GetxController {
  var isLoading = true.obs;
  var rooms = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadRooms();
  }

  Future<void> loadRooms() async {
    try {
      isLoading.value = true;
      final token = GetStorage().read('staff_token');
      
      final response = await http.get(
        Uri.parse('${ApiConstants.apiBaseUrl}/admin/rooms'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        rooms.assignAll(data['data'] ?? []);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load rooms', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> closeRoom(String id) async {
    try {
      final token = GetStorage().read('staff_token');
      final response = await http.post(
        Uri.parse('${ApiConstants.apiBaseUrl}/admin/rooms/close/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        final index = rooms.indexWhere((r) => (r['_id'] ?? r['id']) == id);
        if (index != -1) {
          final room = Map<String, dynamic>.from(rooms[index]);
          room['isActive'] = data['isActive'];
          rooms[index] = room;
        }
        Get.snackbar('Success', 'Room successfully closed.', backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to close room', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}