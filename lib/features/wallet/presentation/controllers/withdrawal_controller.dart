// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/wallet/presentation/controllers/withdrawal_controller.dart
// ARVIND PARTY - WITHDRAWAL CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../../core/services/api_service.dart';

class WithdrawalController extends GetxController {
  var isLoading = false.obs;
  var withdrawalHistory = <Map<String, dynamic>>[].obs;

  final _api = Get.find<ApiService>();

  @override
  void onInit() {
    super.onInit();
    fetchWithdrawalHistory();
  }

  Future<void> fetchWithdrawalHistory() async {
    try {
      isLoading.value = true;
      final response = await _api.get('/wallet/withdrawals/history');
      if (response is Map && response['success'] == true) {
        withdrawalHistory.assignAll(List<Map<String, dynamic>>.from(response['data'] ?? []));
      }
    } catch (e) {
      debugPrint('Fetch withdrawal history error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
