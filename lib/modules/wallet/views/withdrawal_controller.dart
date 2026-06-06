import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/withdrawal_method_model.dart';
import '../../auth/views/api_service.dart';

class WithdrawalController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final isLoading = false.obs;

  // Earning balance (e.g., Beans / Coins earned from gifts)
  final beansBalance = 0.obs;

  // Exchange rate: How many beans equal 1 USD? (e.g., 210 beans = 1 USD)
  final int beansPerUsd = 210;

  final withdrawalMethods = <WithdrawalMethod>[].obs;
  final selectedMethod = Rxn<WithdrawalMethod>();

  final amountController = TextEditingController();

  double get usdEquivalent => beansBalance.value / beansPerUsd;

  @override
  void onInit() {
    super.onInit();
    _loadWithdrawalData();
  }

  void _loadWithdrawalData() async {
    isLoading.value = true;

    try {
      var response = await _apiService.get('wallet/withdrawal-info');
      if (response.statusCode == 200) {
        beansBalance.value = response.data['beansBalance'] ?? 0;

        var methods = (response.data['methods'] as List)
            .map((m) => WithdrawalMethod(
                  id: m['id'],
                  name: m['name'],
                  icon: m['icon'],
                  minWithdrawalUsd: (m['minWithdrawalUsd'] ?? 0).toDouble(),
                  feePercentage: (m['feePercentage'] ?? 0).toDouble(),
                  processingTime: m['processingTime'] ?? 'Standard',
                ))
            .toList();

        withdrawalMethods.assignAll(methods);
        if (withdrawalMethods.isNotEmpty) {
          selectedMethod.value = withdrawalMethods.first;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch wallet info.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void selectMethod(WithdrawalMethod method) {
    selectedMethod.value = method;
  }

  void submitWithdrawal() async {
    final amountStr = amountController.text.trim();
    if (amountStr.isEmpty) {
      Get.snackbar('Error', 'Please enter an amount to withdraw',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final amount = double.tryParse(amountStr) ?? 0.0;
    if (amount < (selectedMethod.value?.minWithdrawalUsd ?? 0)) {
      Get.snackbar('Error',
          'Minimum withdrawal for ${selectedMethod.value?.name} is \$${selectedMethod.value?.minWithdrawalUsd}',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      var response = await _apiService.post('wallet/withdraw', {
        'methodId': selectedMethod.value?.id,
        'amount': amount,
      });
      if (response.statusCode == 200) {
        Get.snackbar('Success',
            'Withdrawal request for \$${amount.toStringAsFixed(2)} submitted.',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 4));
        _loadWithdrawalData(); // Refresh balance after success
      }
    } catch (e) {
      Get.snackbar('Error', 'Withdrawal failed. Please try again.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
