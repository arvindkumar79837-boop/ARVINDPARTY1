// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/wallet/presentation/controllers/withdrawal_controller.dart
// ARVIND PARTY - WITHDRAWAL CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';

class WithdrawalController extends GetxController {
  var isLoading = false.obs;
  var withdrawalHistory = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchWithdrawalHistory();
  }

  Future<void> fetchWithdrawalHistory() async {
    try {
      isLoading.value = true;
      // API integration pending
    } catch (e) {
      // Silent fail
    } finally {
      isLoading.value = false;
    }
  }
}