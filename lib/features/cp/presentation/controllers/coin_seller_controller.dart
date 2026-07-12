import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_session_manager.dart';
import '../../models/coin_seller_model.dart';

class CoinSellerController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final AuthSessionManager _session = Get.find<AuthSessionManager>();

  // Observables for the logged-in dealer's state
  final dealerWallet = Rxn<Map<String, dynamic>>();
  final transactions = <Map<String, dynamic>>[].obs;
  final settlementHistory = <SettlementRecord>[].obs;

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Only load data if the user is a coin seller
    // Coin seller check
    if (true) {
      loadDealerData();
    }
  }

  /// Loads all necessary data for the logged-in dealer from the backend.
  Future<void> loadDealerData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final dealerUid = _session.userId.value ?? '';
      if (dealerUid.isEmpty) {
        throw Exception('User is not logged in or has no UID.');
      }

      // Fetch wallet details and transaction history in parallel
      final results = await Future.wait([
        _api.get('/dealer/wallet/$dealerUid'),
        _api.get('/dealer/transactions/$dealerUid'),
        // Assuming a settlement history endpoint
        _api.get('/dealer/settlements/$dealerUid'),
      ]);

      // Process wallet data
      final walletResponse = results[0];
      if (walletResponse['success'] == true) {
        dealerWallet.value = Map<String, dynamic>.from(walletResponse['data']['wallet']);
      } else {
        throw Exception('Failed to load dealer wallet: ${walletResponse['message']}');
      }

      // Process transaction history
      final txResponse = results[1];
      if (txResponse['success'] == true) {
        final txList = (txResponse['data'] as List).map((tx) => Map<String, dynamic>.from(tx)).toList();
        transactions.assignAll(txList);
      }

      // Process settlement history
      final settlementResponse = results[2];
      if (settlementResponse['success'] == true) {
        final settlementList = (settlementResponse['data'] as List).map((s) => SettlementRecord.fromJson(s)).toList();
        settlementHistory.assignAll(settlementList);
      }

    } catch (e) {
      errorMessage.value = 'Error loading dealer data: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// Transfer coins from the logged-in dealer to a target user.
  Future<bool> transferCoinsToUser({required String targetUid, required int amount}) async {
    isLoading.value = true;
    try {
      if (dealerWallet.value == null || (dealerWallet.value!['balance'] as int? ?? 0) < amount) {
        Get.snackbar('Error', 'Insufficient balance.', backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }
      final response = await _api.post('/dealer/transfer', body: {
        'targetUid': targetUid,
        'amount': amount,
        'description': 'Coin transfer from dealer',
      });

      if (response['success'] == true) {
        Get.snackbar('Success', 'Successfully transferred $amount coins to $targetUid.', backgroundColor: Colors.green);
        // Refresh data after successful transfer
        await loadDealerData();
        return true;
      } else {
        Get.snackbar('Transfer Failed', response['message'] ?? 'An unknown error occurred.', backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: ${e.toString()}', backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Submits a request for the dealer to settle their earnings.
  Future<void> submitSettlement({required double amount, required String method}) async {
    isLoading.value = true;
    try {
      final response = await _api.post('/dealer/settlement-request', body: {
        'amount': amount,
        'method': method, // e.g., 'bank_transfer', 'upi'
      });

       if (response['success'] == true) {
        Get.snackbar('Success', 'Settlement request for \$$amount submitted successfully.', backgroundColor: Colors.green);
        await loadDealerData();
      } else {
        Get.snackbar('Failed', response['message'] ?? 'Could not submit request.', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
       Get.snackbar('Error', 'An error occurred: ${e.toString()}', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}