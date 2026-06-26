// ═══════════════════════════════════════════════════════════════════════════
// FILE: arvind_party_web/lib/modules/family_management/family_controller.dart
// ARVIND PARTY - FAMILY MANAGEMENT CONTROLLER (WEB PANEL)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class FamilyController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final allFamilies = <Map<String, dynamic>>[].obs;
  final selectedFamily = Rxn<Map<String, dynamic>>();
  final isLoading = false.obs;
  final totalItems = 0.obs;
  final currentPage = 1.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllFamilies();
  }

  Future<void> fetchAllFamilies({int page = 1, String search = ''}) async {
    try {
      isLoading.value = true;
      final queryParams = <String, dynamic>{'page': page};
      if (search.isNotEmpty) queryParams['search'] = search;

      final response = await _api.get('/api/families/admin/all', queryParameters: queryParams);
      if (response['success'] == true) {
        allFamilies.assignAll(List<Map<String, dynamic>>.from(response['data'] ?? []));
        totalItems.value = response['total'] ?? 0;
        currentPage.value = response['page'] ?? page;
      }
    } catch (e) {
      print('Error fetching families: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchFamilies(String query) async {
    await fetchAllFamilies(page: 1, search: query);
  }

  Future<bool> updateFamilyStatus(String familyId, bool isActive, String? reason) async {
    try {
      isLoading.value = true;
      final endpoint = isActive ? '/api/families/admin/$familyId/unban' : '/api/families/admin/$familyId/ban';
      final response = await _api.put(endpoint, data: {'reason': reason ?? ''});
      return response['success'] == true;
    } catch (e) {
      print('Error updating family status: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteFamily(String familyId) async {
    try {
      isLoading.value = true;
      final response = await _api.delete('/api/families/admin/$familyId');
      return response['success'] == true;
    } catch (e) {
      print('Error deleting family: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void selectFamily(Map<String, dynamic> family) {
    selectedFamily.value = family;
  }

  Future<void> refreshFamilies() async {
    await fetchAllFamilies(page: currentPage.value);
  }
}