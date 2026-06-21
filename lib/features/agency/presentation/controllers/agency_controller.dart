// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/agency/presentation/controllers/agency_controller.dart
// ARVIND PARTY - AGENCY CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../repositories/agency_repository.dart';

class AgencyController extends GetxController {
  final isLoading = false.obs;
  final isCreating = false.obs;
  final agencyData = Rxn<Map<String, dynamic>>();
  final members = <Map<String, dynamic>>[].obs;
  final earnings = Rxn<Map<String, dynamic>>();

  late final AgencyRepository _agencyRepository = Get.find<AgencyRepository>();

  @override
  void onInit() {
    super.onInit();
    loadAgencyData();
  }

  Future<void> loadAgencyData() async {
    try {
      isLoading.value = true;
      agencyData.value = await _agencyRepository.fetchData();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load agency data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMembers() async {
    try {
      isLoading.value = true;
      final fetchedMembers = await _agencyRepository.fetchMembers();
      members.assignAll(fetchedMembers);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load agency members');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createAgency({
    required String name,
    String? description,
    String? logo,
  }) async {
    try {
      isCreating.value = true;
      final result = await _agencyRepository.createAgency(
        name: name,
        description: description,
        logo: logo,
      );

      if (result['success'] == true) {
        agencyData.value = result['agency'] as Map<String, dynamic>? ?? result;
        Get.back();
        Get.snackbar('Success', 'Agency created successfully');
      } else {
        Get.snackbar('Error', result['message'] ?? 'Failed to create agency');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create agency: ${e.toString()}');
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> fetchEarnings() async {
    try {
      isLoading.value = true;
      earnings.value = await _agencyRepository.fetchEarnings();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch agency earnings');
    } finally {
      isLoading.value = false;
    }
  }
}
