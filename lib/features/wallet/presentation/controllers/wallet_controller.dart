import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/socket/socket_service.dart';
import '../models/wallet_model.dart';

class WalletController extends GetxController {
  var isLoading = false.obs;
  var isRefreshing = false.obs;

  // Coin Wallet
  var coinBalance = 0.obs;

  // Diamond Wallet
  var diamondBalance = 0.obs;

  // Legacy reward balance (mapped to coins)
  var rewardBalance = 0.obs;
  var pendingWithdrawals = 0.obs;
  var userRole = ''.obs;
  var isCoinSeller = false.obs;
  var coinSellerLevel = ''.obs;
  var familyId = ''.obs;
  var agencyId = ''.obs;

  // Family Wallet
  var familyWalletData = Rxn<FamilyWalletData>();
  var familyData = Rxn<FamilyData>();
  var memberContributions = <MemberContribution>[].obs;
  var isFamilyWalletLoading = false.obs;

  // Agency Wallet
  var agencyWalletData = Rxn<AgencyWalletData>();
  var agencyData = Rxn<AgencyData>();
  var agencyHosts = <HostSummary>[].obs;
  var isAgencyWalletLoading = false.obs;
  var isAgencyOwner = false.obs;

  // Gift Coins
  final giftAmountController = TextEditingController();

  // Config & Rates
  var coinBuyRate = 10.0.obs;
  var diamondBuyRate = 0.0.obs;
  var coinToDiamondRate = 100.0.obs;
  var exchangeRate = 100.obs;
  var taxPercentage = 5.obs;
  var minWithdrawal = 500.obs;

  // Today Income
  var todayIncome = Rxn<TodayIncome>();

  // Transactions
  var transactions = <TransactionModel>[].obs;
  var familyTransactions = <TransactionModel>[].obs;
  var agencyTransactions = <TransactionModel>[].obs;

  // Recharge
  var packages = <RechargePackage>[].obs;
  var selectedPackage = Rxn<RechargePackage>();
  var selectedPaymentMethod = 'upi'.obs;
  var isProcessingRecharge = false.obs;
  var withdrawAmountController = TextEditingController();
  var accountDetailsController = TextEditingController();
  var selectedWithdrawMethod = 'diamonds'.obs;
  var withdrawMethods = <WithdrawMethod>[].obs;
  var isProcessingWithdraw = false.obs;

  // Family contribution
  var contributionCoinsController = TextEditingController();
  var contributionDiamondsController = TextEditingController();
  var isContributing = false.obs;

  final ApiService _api = Get.find<ApiService>();
  final SocketService _socket = Get.find<SocketService>();

  @override
  void onInit() {
    super.onInit();
    loadAllData();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    _socket.on('withdrawal_approved', _handleWithdrawalApproved);
    _socket.on('withdrawal_rejected', _handleWithdrawalRejected);
    _socket.on('withdrawal_paid', _handleWithdrawalPaid);
  }

  void _handleWithdrawalApproved(dynamic data) {
    Get.snackbar('Withdrawal Approved', 'Your withdrawal request has been approved',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.9), colorText: Colors.white);
    fetchWithdrawalStatus();
  }

  void _handleWithdrawalRejected(dynamic data) {
    Get.snackbar('Withdrawal Rejected', data['reason'] ?? 'Your withdrawal request was rejected',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
    fetchWithdrawalStatus();
  }

  void _handleWithdrawalPaid(dynamic data) {
    Get.snackbar('Payment Sent', 'Withdrawal of ₹${data['amountINR']} has been processed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.9), colorText: Colors.white);
    fetchWithdrawalStatus();
  }

  @override
  void onClose() {
    _socket.off('withdrawal_approved');
    _socket.off('withdrawal_rejected');
    _socket.off('withdrawal_paid');
    withdrawAmountController.dispose();
    accountDetailsController.dispose();
    contributionCoinsController.dispose();
    contributionDiamondsController.dispose();
    giftAmountController.dispose();
    super.onClose();
  }

  Future<void> loadAllData() async {
    await Future.wait([
      fetchMainWallet(),
      fetchPackages(),
      fetchWithdrawMethods(),
    ]);
  }

  Future<void> fetchMainWallet() async {
    try {
      isLoading.value = true;
      final response = await _api.get('/api/wallet');
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        coinBalance.value = data['coins'] ?? 0;
        diamondBalance.value = data['diamonds'] ?? 0;
        pendingWithdrawals.value = data['pendingWithdrawals'] ?? 0;
        userRole.value = data['role'] ?? '';
        isCoinSeller.value = data['isCoinSeller'] ?? false;
        coinSellerLevel.value = data['coinSellerLevel'] ?? '';
        familyId.value = data['familyId'] ?? '';
        agencyId.value = data['agencyId'] ?? '';

        if (data['familyWallet'] != null) {
          familyWalletData.value = FamilyWalletData.fromJson(data['familyWallet']);
        }
        if (data['agencyWallet'] != null) {
          agencyWalletData.value = AgencyWalletData.fromJson(data['agencyWallet']);
        }
        if (data['todayIncome'] != null) {
          todayIncome.value = TodayIncome.fromJson(data['todayIncome']);
        }
        if (data['config'] != null) {
          final cfg = data['config'];
          exchangeRate.value = cfg['exchangeRate'] ?? 100;
          coinBuyRate.value = (cfg['coinPackageRate'] ?? 10).toDouble();
          minWithdrawal.value = cfg['minWithdrawal'] ?? 500;
          taxPercentage.value = cfg['taxPercentage'] ?? 5;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load wallet: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTransactions({String? walletType}) async {
    try {
      isRefreshing.value = true;
      final queryParams = walletType != null ? '?walletType=$walletType' : '';
      final response = await _api.get('/api/wallet/transactions$queryParams');
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final List<dynamic> txns = data['transactions'] ?? [];
        transactions.value = txns.map((t) => TransactionModel.fromJson(t)).toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load transactions: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
    } finally {
      isRefreshing.value = false;
    }
  }

  // ===================== FAMILY WALLET =====================

  Future<void> fetchFamilyWallet() async {
    try {
      isFamilyWalletLoading.value = true;
      final response = await _api.get('/api/wallet/family');
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        if (data['wallet'] != null) {
          familyWalletData.value = FamilyWalletData.fromJson(data['wallet']);
        }
        if (data['family'] != null) {
          familyData.value = FamilyData.fromJson(data['family']);
        }
        if (data['contributions'] != null) {
          memberContributions.value = (data['contributions'] as List)
              .map((c) => MemberContribution.fromJson(c))
              .toList();
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load family wallet: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
    } finally {
      isFamilyWalletLoading.value = false;
    }
  }

  Future<void> fetchFamilyTransactions() async {
    try {
      isRefreshing.value = true;
      final response = await _api.get('/api/wallet/family/transactions');
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final List<dynamic> txns = data['transactions'] ?? [];
        familyTransactions.value = txns.map((t) => TransactionModel.fromJson(t)).toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load family transactions: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> contributeToFamilyWallet() async {
    final coins = int.tryParse(contributionCoinsController.text) ?? 0;
    final diamonds = int.tryParse(contributionDiamondsController.text) ?? 0;

    if (coins <= 0 && diamonds <= 0) {
      Get.snackbar('Error', 'Enter coins or diamonds to contribute',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
      return;
    }

    try {
      isContributing.value = true;
      final response = await _api.post('/api/wallet/family/contribute', body: {
        'coins': coins,
        'diamonds': diamonds,
      });
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        coinBalance.value = data['coinsRemaining'] ?? coinBalance.value;
        diamondBalance.value = data['diamondsRemaining'] ?? diamondBalance.value;
        if (data['familyWallet'] != null) {
          familyWalletData.value = FamilyWalletData.fromJson(data['familyWallet']);
        }
        Get.snackbar('Success', 'Contributed to family wallet',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
        contributionCoinsController.clear();
        contributionDiamondsController.clear();
        await fetchFamilyWallet();
      }
    } catch (e) {
      Get.snackbar('Error', 'Contribution failed: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
    } finally {
      isContributing.value = false;
    }
  }

  // ===================== AGENCY WALLET =====================

  Future<void> fetchAgencyWallet() async {
    try {
      isAgencyWalletLoading.value = true;
      final response = await _api.get('/api/wallet/agency');
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        if (data['wallet'] != null) {
          agencyWalletData.value = AgencyWalletData.fromJson(data['wallet']);
        }
        if (data['agency'] != null) {
          agencyData.value = AgencyData.fromJson(data['agency']);
        }
        if (data['hosts'] != null) {
          agencyHosts.value = (data['hosts'] as List)
              .map((h) => HostSummary.fromJson(h))
              .toList();
        }
        isAgencyOwner.value = data['isOwner'] ?? false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load agency wallet: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
    } finally {
      isAgencyWalletLoading.value = false;
    }
  }

  Future<void> fetchAgencyTransactions() async {
    try {
      final response = await _api.get('/api/wallet/agency/transactions');
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final List<dynamic> txns = data['transactions'] ?? [];
        agencyTransactions.value = txns.map((t) => TransactionModel.fromJson(t)).toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load agency transactions: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
    }
  }

  Future<void> requestAgencyWithdrawal() async {
    final amount = int.tryParse(withdrawAmountController.text);
    if (amount == null || amount <= 0) {
      Get.snackbar('Error', 'Enter a valid withdrawal amount',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
      return;
    }
    try {
      isProcessingWithdraw.value = true;
      final response = await _api.post('/api/wallet/agency/withdraw/request', body: {
        'amount': amount,
      });
      if (response['success'] == true) {
        Get.snackbar('Success', 'Agency withdrawal request submitted',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
        withdrawAmountController.clear();
        await fetchAgencyWallet();
      }
    } catch (e) {
      Get.snackbar('Error', 'Agency withdrawal failed: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
    } finally {
      isProcessingWithdraw.value = false;
    }
  }

  // ===================== RECHARGE =====================

  Future<void> fetchPackages() async {
    try {
      final response = await _api.get('/api/wallet/packages');
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> pkgs = response['data'];
        packages.value = pkgs.map((p) => RechargePackage.fromJson(p)).toList();
      }
    } catch (e) {
    }
  }

  Future<void> fetchWithdrawMethods() async {
    try {
      final response = await _api.get('/api/wallet/withdraw-methods');
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> methods = response['data'];
        withdrawMethods.value = methods.map((m) => WithdrawMethod.fromJson(m)).toList();
      }
    } catch (e) {
    }
  }

  Future<void> processRecharge() async {
    if (selectedPackage.value == null) {
      Get.snackbar('Error', 'Please select a package',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
      return;
    }

    try {
      isProcessingRecharge.value = true;
      final response = await _api.post('/api/wallet/recharge/create-order', body: {
        'amount': selectedPackage.value!.price,
        'packageId': selectedPackage.value!.id,
      });
      if (response['success'] == true && response['data'] != null) {
        Get.snackbar('Order Created', 'Redirecting to payment...',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.blue.withValues(alpha: 0.8), colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Recharge failed: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
    } finally {
      isProcessingRecharge.value = false;
    }
  }

  // ===================== WITHDRAWAL =====================

  Future<void> processWithdraw() async {
    final amount = double.tryParse(withdrawAmountController.text);
    if (amount == null || amount <= 0) {
      Get.snackbar('Error', 'Please enter a valid amount',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
      return;
    }

    try {
      isProcessingWithdraw.value = true;
      final body = <String, dynamic>{
        'bankAccount': accountDetailsController.text,
        'ifsc': '',
        'accountName': '',
      };
      if (selectedWithdrawMethod.value == 'diamonds') {
        body['diamonds'] = amount.toInt();
      } else {
        body['amount'] = amount.toInt();
      }
      final response = await _api.post('/api/wallet/withdraw/request', body: body);
      if (response['success'] == true) {
        Get.snackbar('Success', 'Withdrawal request submitted',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
        withdrawAmountController.clear();
        accountDetailsController.clear();
        fetchWithdrawalStatus();
      }
    } catch (e) {
      Get.snackbar('Error', 'Withdrawal failed: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
    } finally {
      isProcessingWithdraw.value = false;
    }
  }

  Future<void> fetchWithdrawalStatus() async {
    try {
      final response = await _api.get('/api/wallet/withdraw/status');
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> withdrawals = response['data'] ?? [];
        pendingWithdrawals.value = withdrawals.where((w) => w['status'] == 'PENDING' || w['status'] == 'PROCESSING').length;
      }
    } catch (e) {
    }
  }

  // ===================== DIAMOND EXCHANGE =====================

  Future<void> exchangeDiamondsToCoins() async {
    try {
      final amount = int.tryParse(withdrawAmountController.text);
      if (amount == null || amount <= 0) {
        Get.snackbar('Error', 'Enter valid diamond amount',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
        return;
      }
      final response = await _api.post('/api/wallet/exchange', body: {'diamondsToExchange': amount});
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        coinBalance.value = data['coinsReceived'] ?? coinBalance.value;
        diamondBalance.value = data['diamondsRemaining'] ?? diamondBalance.value;
        Get.snackbar('Success', 'Exchanged ${data['diamondsExchanged']} diamonds to ${data['coinsReceived']} coins',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
        withdrawAmountController.clear();
      }
    } catch (e) {
      Get.snackbar('Error', 'Exchange failed: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
    }
  }

  // ===================== SEND GIFT COINS =====================

  Future<void> sendGiftCoins(int amount) async {
    try {
      final response = await _api.post('/api/wallet/send', body: {
        'amount': amount,
        'type': 'gift',
      });
      if (response['success'] == true) {
        coinBalance.value -= amount;
        Get.snackbar('Gift Sent!', '$amount coins sent as gift',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send gift coins: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
    }
  }

  // ===================== SEND GIFT =====================

  Future<void> sendGift(String recipientId, String giftId, String giftName, int quantity, int costPerGift) async {
    try {
      final response = await _api.post('/api/wallet/gift/send', body: {
        'recipientId': recipientId,
        'giftId': giftId,
        'giftName': giftName,
        'quantity': quantity,
        'costPerGift': costPerGift,
      });
      if (response['success'] == true && response['data'] != null) {
        coinBalance.value = response['data']['coinsRemaining'] ?? coinBalance.value;
        Get.snackbar('Success', 'Gift sent successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.8), colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gift failed: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8), colorText: Colors.white);
      rethrow;
    }
  }

  // ===================== FORMATTING HELPERS =====================

  String formatCurrency(int amount) {
    if (amount >= 10000000) return '${(amount / 10000000).toStringAsFixed(1)}Cr';
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toString();
  }

  String formatCurrencyDouble(double amount) {
    if (amount >= 10000000) return '${(amount / 10000000).toStringAsFixed(1)}Cr';
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(2);
  }

  // ===================== MISSING GETTERS/METHODS =====================

  Balance get balance => Balance(
    coins: coinBalance.value,
    diamonds: diamondBalance.value,
    beans: rewardBalance.value,
  );

  Future<void> fetchCoinWallet() async => loadAllData();
  Future<void> fetchDiamondWallet() async => loadAllData();
  Future<void> fetchTreasuryData() async => loadAllData();

  var treasuryBalance = 0.obs;
  var totalTransactions = 0.obs;
  var totalRevenue = 0.0.obs;
  var isTreasuryLoading = false.obs;
  var treasuryTransactions = <Map<String, dynamic>>[].obs;
  var rewardConversionRate = 100.obs;
  var minConversionAmount = 100.obs;
  var rewardTransactions = <Map<String, dynamic>>[].obs;

  Future<void> fetchRewardTransactions() async {
    try {
      final response = await _api.get('/api/wallet/rewards/transactions');
      if (response['success'] == true && response['data'] != null) {
        rewardTransactions.value = List<Map<String, dynamic>>.from(response['data']);
      }
    } catch (e) {
    }
  }

  Future<void> convertRewardsToCoins() async {
    try {
      final response = await _api.post('/api/wallet/rewards/convert', body: {});
      if (response['success'] == true) {
        Get.snackbar('Success', 'Rewards converted to coins');
        loadAllData();
      }
    } catch (e) {
      Get.snackbar('Error', 'Conversion failed: $e');
    }
  }

  Future<void> creditTreasury(double amount, String description) async {
    try {
      final response = await _api.post('/api/wallet/treasury/credit', body: {
        'amount': amount,
        'description': description,
      });
      if (response['success'] == true) {
        Get.snackbar('Success', 'Credited $amount to treasury');
        loadAllData();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to credit treasury: $e');
    }
  }

  Future<void> debitTreasury(double amount, String description) async {
    try {
      final response = await _api.post('/api/wallet/treasury/debit', body: {
        'amount': amount,
        'description': description,
      });
      if (response['success'] == true) {
        Get.snackbar('Success', 'Debited $amount from treasury');
        loadAllData();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to debit treasury: $e');
    }
  }
}

class Balance {
  final int coins;
  final int diamonds;
  final int beans;

  Balance({required this.coins, required this.diamonds, required this.beans});
}