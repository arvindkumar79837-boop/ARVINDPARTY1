// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/search/presentation/controllers/search_controller.dart
// ARVIND PARTY - SEARCH CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';

class SearchController extends GetxController {
  final isLoading = false.obs;
  final query = ''.obs;
  final results = <Map<String, dynamic>>[].obs;
  final searchType = 'users'.obs;

  final ApiService _apiService = Get.find<ApiService>();

  Future<void> search(String q) async {
    query.value = q;
    if (q.trim().isEmpty) {
      results.clear();
      return;
    }
    try {
      isLoading.value = true;
      final response = await _apiService.get(
        ApiConstants.userSearch,
        query: {'q': q, 'type': searchType.value},
      );
      if (response is Map && response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          results.value = List<Map<String, dynamic>>.from(data);
        } else {
          results.clear();
        }
      } else {
        results.clear();
      }
    } catch (e) {
      Get.snackbar('Error', 'Search failed: $e');
      results.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void setSearchType(String type) {
    searchType.value = type;
    if (query.value.isNotEmpty) {
      search(query.value);
    }
  }

  void clearSearch() {
    query.value = '';
    results.clear();
  }

}
