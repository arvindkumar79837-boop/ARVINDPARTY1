// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/lucky_draw/presentation/controllers/lucky_draw_controller.dart
// ARVIND PARTY - LUCKY DRAW CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../repositories/lucky_draw_repository.dart';

class LuckyDrawController extends GetxController {
  final isLoading = false.obs;
  final isSpinning = false.obs;
  final rewards = <Map<String, dynamic>>[].obs;
  final prize = Rxn<Map<String, dynamic>>();
  final newBalance = 0.obs;

  final LuckyDrawRepository _repo = LuckyDrawRepository();

  @override
  void onInit() {
    super.onInit();
    loadRewards();
  }

  Future<void> loadRewards() async {
    try {
      isLoading.value = true;
      final fetched = await _repo.fetchRewards();
      rewards.assignAll(fetched);
    } catch (e) {
      // Silent fail — rewards are optional for UI; spinner still works
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> spin() async {
    if (isSpinning.value) return;
    try {
      isSpinning.value = true;
      prize.value = null;
      final result = await _repo.spin();

      if (result['reward'] != null) {
        prize.value = result['reward'] as Map<String, dynamic>;
      } else {
        prize.value = {'name': result['message'] ?? 'Try Again!', 'type': 'info', 'value': 0};
      }
      newBalance.value = result['newBalance'] as int? ?? 0;

      Get.snackbar(
        'Congratulations!',
        'You won ${prize.value?['name'] ?? 'a prize'}!',
      );
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('Spin Failed', msg);
    } finally {
      isSpinning.value = false;
    }
  }
}
