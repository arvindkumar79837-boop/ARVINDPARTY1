// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/family/presentation/controllers/family_controller.dart
// ARVIND PARTY - FAMILY CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../repositories/family_repository.dart';

class FamilyController extends GetxController {
  final isLoading = false.obs;
  final families = <Map<String, dynamic>>[].obs;
  final selectedFamily = Rxn<Map<String, dynamic>>();
  final FamilyRepository _repo = FamilyRepository();

  @override
  void onInit() {
    super.onInit();
    fetchFamilies();
  }

  Future<void> fetchFamilies() async {
    try {
      isLoading.value = true;
      final result = await _repo.fetchFamilies();
      families.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load families');
    } finally {
      isLoading.value = false;
    }
  }
}
