import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/dealer_model.dart';
import '../../services/dealer_service.dart';

class DealerController extends GetxController {
  static DealerController get to => Get.find<DealerController>();
  final DealerService _service = Get.find<DealerService>();

  var isLoading = false.obs;
  var wallet = Rxn<DealerWalletModel>();
  var stats = Rxn<DealerStats>();
  var transactions = <dynamic>[].obs;
  var allDealers = Rxn<DealerListResponse>();

  var dealersList = <DealerWalletModel>[].obs;
  var totalDealers = 0.obs;
  var activeDealers = 0.obs;
  var flaggedDealers = 0.obs;
  var verifiedDealers = 0.obs;
  var totalDealerBalance = 0.obs;

  var refundRequests = <DealerRefundModel>[].obs;

  var currentPage = 1.obs;
  var totalPages = 1.obs;

  var targetUidController = TextEditingController();
  var amountController = TextEditingController();
  var reasonController = TextEditingController();
  var descriptionController = TextEditingController();

  var refundTransactionHashController = TextEditingController();
  var refundCoinsController = TextEditingController();
  var refundReasonController = TextEditingController();
  var refundErrorDescriptionController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchDealerWallet();
    fetchDealerStats();
  }

  Future<void> fetchDealerWallet() async {
    try {
      isLoading.value = true;
      final uid = await _getCurrentDealerUid();
      if (uid == null) return;
      final result = await _service.getDealerWallet(uid);
      wallet.value = result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load dealer wallet: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDealerStats() async {
    try {
      final uid = await _getCurrentDealerUid();
      if (uid == null) return;
      final result = await _service.getDealerStats(uid);
      stats.value = result;
    } catch (e) {
    }
  }

  Future<void> fetchDealerTransactions({int page = 1, int limit = 50}) async {
    try {
      isLoading.value = true;
      final uid = await _getCurrentDealerUid();
      if (uid == null) return;
      final result = await _service.getDealerTransactions(uid, page: page, limit: limit);
      transactions.value = result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load transactions: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> transferCoinsToUser() async {
    final targetUid = targetUidController.text.trim();
    final amount = int.tryParse(amountController.text.trim());
    final reason = reasonController.text.trim();
    final description = descriptionController.text.trim();

    if (targetUid.isEmpty || amount == null || amount <= 0) {
      Get.snackbar('Error', 'Please enter a valid target UID and amount',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
      return;
    }

    final currentWallet = wallet.value;
    if (currentWallet == null) {
      Get.snackbar('Error', 'Dealer wallet not loaded',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
      return;
    }

    if (amount > currentWallet.remainingDailyLimit) {
      Get.snackbar('Error', 'Amount exceeds remaining daily limit',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
      return;
    }

    if (amount > currentWallet.maxTransferPerTransaction) {
      Get.snackbar('Error', 'Amount exceeds max per transaction limit',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      final result = await _service.transferCoinsToUser(
        targetUid: targetUid,
        amount: amount,
        reason: reason.isEmpty ? null : reason,
        description: description.isEmpty ? null : description,
      );

      if (result != null) {
        Get.snackbar(
          'Success',
          '${result.amountTransferred} coins transferred to ${result.targetUid}\nTransaction Hash: ${result.transactionHash.substring(0, 16)}...',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        targetUidController.clear();
        amountController.clear();
        reasonController.clear();
        descriptionController.clear();
        await fetchDealerWallet();
        await fetchDealerStats();
        await fetchDealerTransactions();
      } else {
        Get.snackbar('Error', 'Transfer failed. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.8),
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Transfer error: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> requestRefund() async {
    final transactionHash = refundTransactionHashController.text.trim();
    final coinsToRefund = int.tryParse(refundCoinsController.text.trim());
    final reason = refundReasonController.text.trim();
    final errorDescription = refundErrorDescriptionController.text.trim();

    if (transactionHash.isEmpty || coinsToRefund == null || coinsToRefund <= 0 || reason.isEmpty) {
      Get.snackbar('Error', 'Please fill all required fields',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      final result = await _service.requestRefund(
        transactionHash: transactionHash,
        coinsToRefund: coinsToRefund,
        reason: reason,
        errorDescription: errorDescription.isEmpty ? null : errorDescription,
      );

      if (result != null) {
        Get.snackbar(
          'Success',
          'Refund request submitted. Refund ID: ${result.refundId}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        refundTransactionHashController.clear();
        refundCoinsController.clear();
        refundReasonController.clear();
        refundErrorDescriptionController.clear();
        await fetchDealerStats();
      } else {
        Get.snackbar('Error', 'Failed to submit refund request',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.8),
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Refund request error: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllDealers({String? level, bool? isActive, bool? isFlagged, bool? isVerified}) async {
    try {
      isLoading.value = true;
      final result = await _service.getAllDealers(level: level, isActive: isActive, isFlagged: isFlagged, isVerified: isVerified);
      if (result != null) {
        allDealers.value = result;
        dealersList.value = result.dealers;
        totalDealers.value = result.stats.totalDealers;
        activeDealers.value = result.stats.activeDealers;
        flaggedDealers.value = result.stats.flaggedDealers;
        verifiedDealers.value = result.stats.verifiedDealers;
        totalDealerBalance.value = result.stats.totalBalance;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load dealers: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateDealerLevel(String dealerUid, String level) async {
    final success = await _service.updateDealerLevel(dealerUid, level: level);
    if (success) {
      Get.snackbar('Success', 'Dealer level updated to $level',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white);
      await fetchAllDealers();
    }
  }

  Future<void> toggleDealerActiveStatus(String dealerUid, bool currentStatus) async {
    final newStatus = !currentStatus;
    final success = await _service.toggleDealerStatus(dealerUid, newStatus);
    if (success) {
      Get.snackbar('Success', 'Dealer ${newStatus ? 'activated' : 'deactivated'}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white);
      await fetchAllDealers();
    }
  }

  Future<void> creditDealerWallet(String dealerUid, int amount) async {
    if (amount <= 0) {
      Get.snackbar('Error', 'Please enter a valid amount',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
      return;
    }
    final success = await _service.creditDealerWallet(dealerUid, amount);
    if (success) {
      Get.snackbar('Success', '$amount coins credited to dealer $dealerUid',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white);
      await fetchAllDealers();
    }
  }

  Future<String?> _getCurrentDealerUid() async {
    return null;
  }

  @override
  void onClose() {
    targetUidController.dispose();
    amountController.dispose();
    reasonController.dispose();
    descriptionController.dispose();
    refundTransactionHashController.dispose();
    refundCoinsController.dispose();
    refundReasonController.dispose();
    refundErrorDescriptionController.dispose();
    super.onClose();
  }
}