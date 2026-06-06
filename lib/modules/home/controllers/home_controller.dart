import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../auth/views/api_service.dart';

class HomeController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final isLoading = false.obs;
  final isSearching = false.obs;
  final liveRooms = <Map<String, dynamic>>[].obs;

  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchLiveRooms();
  }

  Future<void> fetchLiveRooms() async {
    isLoading.value = true;
    try {
      var response = await _apiService.get('rooms/live');

      if (response.statusCode == 200) {
        // Handle both standard JSON arrays and nested 'rooms' objects mapping
        if (response.data['rooms'] != null) {
          liveRooms.assignAll(
              List<Map<String, dynamic>>.from(response.data['rooms']));
        } else if (response.data is List) {
          liveRooms.assignAll(List<Map<String, dynamic>>.from(response.data));
        }
      }
    } catch (e) {
      Get.snackbar('Discovery Error', 'Failed to fetch live rooms.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchController.clear();
      fetchLiveRooms(); // Reset to default feed
    }
  }

  Future<void> searchRooms(String query) async {
    if (query.trim().isEmpty) {
      fetchLiveRooms();
      return;
    }

    isLoading.value = true;
    try {
      var response =
          await _apiService.get('rooms/search', queryParameters: {'q': query});
      if (response.statusCode == 200) {
        liveRooms.assignAll(List<Map<String, dynamic>>.from(response.data));
      }
    } catch (e) {
      Get.snackbar('Search Error', 'Failed to find rooms.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
