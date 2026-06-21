// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/wallet/controllers/wallet_controller.dart
// ARVIND PARTY - WALLET CONTROLLER (Coin, Diamond, Reward, Treasury)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/wallet_model.dart';

class WalletController extends GetxController {
  // Loading states
  var isLoading = false.obs;
  var isRefreshing = false.obs;

  // Wallet balances
  var coinBalance = 0.obs;
  var diamondBalance = 0.obs;
  var rewardBalance = 0.obs;
  
  // For compatibility with views expecting WalletBalance object
  WalletBalance get balance => WalletBalance(
    coins: coinBalance.value,
    diamonds: diamondBalance.value,
    beans: rewardBalance.value,
  );

  // Buying rates
  var coinBuyRate = 0.0.obs;
  var diamondBuyRate = 0.0.obs;
  var coinToDiamondRate = 0.0.obs;

  // Transaction history
  var transactions = <TransactionModel>[].obs;
  var rewardTransactions = <TransactionModel>[].obs;
  var treasuryTransactions = <TransactionModel>[].obs;

  // Recharge
  var packages = <RechargePackage>[].obs;
  var selectedPackage = Rxn<RechargePackage>();
  var selectedPaymentMethod = 'upi'.obs;
  var isProcessingRecharge = false.obs;
  var withdrawAmountController = TextEditingController();
  var accountDetailsController = TextEditingController();
  var selectedWithdrawMethod = 'bank_transfer'.obs;
  var withdrawMethods = <WithdrawMethod>[].obs;
  var isProcessingWithdraw = false.obs;

  // Reward wallet
  var rewardConversionRate = 0.0.obs;
  var minConversionAmount = 100.obs;
  var isProcessingConversion = false.obs;

  // Treasury (admin)
  var treasuryBalance = 0.0.obs;
  var totalTransactions = 0.obs;
  var totalRevenue = 0.0.obs;
  var isTreasuryLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllData();
  }

  Future<void> loadAllData() async {
    await Future.wait([
      fetchCoinWallet(),
      fetchDiamondWallet(),
      fetchRewardWallet(),
      fetchPackages(),
      fetchWithdrawMethods(),
    ]);
  }

  // ═══════ COIN WALLET ═══════

  Future<void> fetchCoinWallet() async {
    try {
      isLoading.value = true;
      // API integration pending
    } catch (e) {
      Get.snackbar('Error', 'Failed to load coin wallet: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCoinTransactions() async {
    try {
      isRefreshing.value = true;
      // API integration pending
    } catch (e) {
      Get.snackbar('Error', 'Failed to load transactions: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
    } finally {
      isRefreshing.value = false;
    }
  }

  // ═══════ DIAMOND WALLET ═══════

  Future<void> fetchDiamondWallet() async {
    try {
      // API integration pending
    } catch (e) {
      Get.snackbar('Error', 'Failed to load diamond wallet: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
    }
  }

  Future<void> fetchDiamondTransactions() async {
    try {
      isRefreshing.value = true;
      // API integration pending
    } catch (e) {
      Get.snackbar('Error', 'Failed to load transactions: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
    } finally {
      isRefreshing.value = false;
    }
  }

  // ═══════ REWARD WALLET ═══════

  Future<void> fetchRewardWallet() async {
    try {
      // API integration pending
    } catch (e) {
      Get.snackbar('Error', 'Failed to load reward wallet: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
    }
  }

  Future<void> fetchRewardTransactions() async {
    try {
      isRefreshing.value = true;
      // API integration pending
    } catch (e) {
      Get.snackbar('Error', 'Failed to load reward history: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> convertRewardsToCoins(int rewardPoints) async {
    if (rewardPoints < minConversionAmount.value) {
      Get.snackbar('Error', 'Minimum conversion amount is $minConversionAmount points',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
      return;
    }

    try {
      isProcessingConversion.value = true;
      // API integration pending
      Get.snackbar('Success', 'Converted $rewardPoints points',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Conversion failed: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
    } finally {
      isProcessingConversion.value = false;
    }
  }

  // ═══════ RATES & PACKAGES ═══════

  Future<void> fetchPackages() async {
    try {
      // API integration pending
    } catch (e) {
      // Silent fail for rates
    }
  }

  Future<void> fetchWithdrawMethods() async {
    try {
      // API integration pending
    } catch (e) {
      // Silent fail
    }
  }

  // ═══════ RECHARGE & WITHDRAW ═══════

  Future<void> processRecharge() async {
    if (selectedPackage.value == null) {
      Get.snackbar('Error', 'Please select a package',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
      return;
    }

    try {
      isProcessingRecharge.value = true;
      // API integration pending
    } catch (e) {
      Get.snackbar('Error', 'Recharge failed: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
    } finally {
      isProcessingRecharge.value = false;
    }
  }

  Future<void> processWithdraw() async {
    final amount = double.tryParse(withdrawAmountController.text);
    if (amount == null || amount <= 0) {
      Get.snackbar('Error', 'Please enter a valid amount',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
      return;
    }

    if (accountDetailsController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter account details',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
      return;
    }

    try {
      isProcessingWithdraw.value = true;
      // API integration pending
    } catch (e) {
      Get.snackbar('Error', 'Withdrawal failed: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
    } finally {
      isProcessingWithdraw.value = false;
    }
  }

  // ═══════ TREASURY (ADMIN) ═══════

  Future<void> fetchTreasuryData() async {
    try {
      isTreasuryLoading.value = true;
      // API integration pending
    } catch (e) {
      Get.snackbar('Error', 'Failed to load treasury data: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
    } finally {
      isTreasuryLoading.value = false;
    }
  }

  Future<void> creditTreasury(double amount, String description) async {
    try {
      isTreasuryLoading.value = true;
      await fetchTreasuryData();
      Get.snackbar('Success', 'Credited $amount to treasury',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Credit failed: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
    } finally {
      isTreasuryLoading.value = false;
    }
  }

  Future<void> debitTreasury(double amount, String description) async {
    try {
      isTreasuryLoading.value = true;
      await fetchTreasuryData();
      Get.snackbar('Success', 'Debited $amount from treasury',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Debit failed: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
    } finally {
      isTreasuryLoading.value = false;
    }
  }

  String formatCurrency(int amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toString();
  }

  String formatCurrencyDouble(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(2);
  }

  @override
  void onClose() {
    withdrawAmountController.dispose();
    accountDetailsController.dispose();
    super.onClose();
  }
}