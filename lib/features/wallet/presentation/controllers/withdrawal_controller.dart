// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/wallet/presentation/controllers/withdrawal_controller.dart
// ARVIND PARTY - WITHDRAWAL CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/api_service.dart';

class WithdrawalController extends GetxController {
  var isLoading = false.obs;
  var isProcessing = false.obs;
  var withdrawalHistory = <Map<String, dynamic>>[].obs;
  var pendingCount = 0.obs;
  var approvedCount = 0.obs;
  var rejectedCount = 0.obs;
  var selectedFilter = 'all'.obs;

  final _api = Get.find<ApiService>();

  @override
  void onInit() {
    super.onInit();
    fetchWithdrawalHistory();
  }

  Future<void> fetchWithdrawalHistory() async {
    try {
      isLoading.value = true;
      final response = await _api.get('/api/wallet/withdraw/history');
      if (response is Map && response['success'] == true) {
        withdrawalHistory.assignAll(List<Map<String, dynamic>>.from(response['data'] ?? []));
        _computeCounts();
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _computeCounts() {
    pendingCount.value = withdrawalHistory.where((w) => w['status'] == 'PENDING').length;
    approvedCount.value = withdrawalHistory.where((w) => w['status'] == 'APPROVED' || w['status'] == 'PAID').length;
    rejectedCount.value = withdrawalHistory.where((w) => w['status'] == 'REJECTED').length;
  }

  List<Map<String, dynamic>> get filteredHistory {
    if (selectedFilter.value == 'all') return withdrawalHistory;
    return withdrawalHistory.where((w) => w['status'] == selectedFilter.value.toUpperCase()).toList();
  }

  Future<void> cancelWithdrawal(String id) async {
    try {
      isProcessing.value = true;
      final response = await _api.post('/api/wallet/withdraw/cancel/$id', body: {});
      if (response is Map && response['success'] == true) {
        Get.snackbar('Cancelled', 'Withdrawal request cancelled',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.withValues(alpha: 0.8),
            colorText: Colors.white);
        await fetchWithdrawalHistory();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
    } finally {
      isProcessing.value = false;
    }
  }

}
