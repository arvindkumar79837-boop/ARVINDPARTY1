import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/dealer_model.dart';

class DealerService extends GetxService {
  static DealerService get to => Get.find<DealerService>();
  late Dio _dio;

  @override
  void onInit() {
    super.onInit();
    _dio = Get.find<Dio>();
  }

  Future<DealerWalletModel?> getDealerWallet(String dealerUid) async {
    try {
      final response = await _dio.get('/api/dealer/wallet/$dealerUid');
      if (response.data['success'] == true) {
        return DealerWalletModel.fromJson(response.data['data']['wallet']);
      }
      return null;
    } catch (e) {
      debugPrint('Get Dealer Wallet Error: $e');
      return null;
    }
  }

  Future<DealerTransferResponse?> transferCoinsToUser({
    required String targetUid,
    required int amount,
    String? reason,
    String? description,
  }) async {
    try {
      final response = await _dio.post('/api/dealer/transfer', data: {
        'targetUid': targetUid,
        'amount': amount,
        if (reason != null) 'reason': reason,
        if (description != null) 'description': description,
      });
      if (response.data['success'] == true) {
        return DealerTransferResponse.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Transfer Coins Error: $e');
      return null;
    }
  }

  Future<DealerRefundModel?> requestRefund({
    required String transactionHash,
    required int coinsToRefund,
    required String reason,
    String? errorDescription,
  }) async {
    try {
      final response = await _dio.post('/api/dealer/refund/request', data: {
        'transactionHash': transactionHash,
        'coinsToRefund': coinsToRefund,
        'reason': reason,
        if (errorDescription != null) 'errorDescription': errorDescription,
      });
      if (response.data['success'] == true) {
        return DealerRefundModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Request Refund Error: $e');
      return null;
    }
  }

  Future<List<dynamic>> getDealerTransactions(String dealerUid, {int page = 1, int limit = 50}) async {
    try {
      final response = await _dio.get('/api/dealer/transactions/$dealerUid', queryParameters: {
        'page': page,
        'limit': limit,
      });
      if (response.data['success'] == true) {
        return response.data['data']['transactions'] ?? [];
      }
      return [];
    } catch (e) {
      debugPrint('Get Dealer Transactions Error: $e');
      return [];
    }
  }

  Future<DealerStats?> getDealerStats(String dealerUid) async {
    try {
      final response = await _dio.get('/api/dealer/stats/$dealerUid');
      if (response.data['success'] == true) {
        return DealerStats.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Get Dealer Stats Error: $e');
      return null;
    }
  }

  Future<DealerListResponse?> getAllDealers({int page = 1, int limit = 50, String? level, bool? isActive, bool? isFlagged, bool? isVerified}) async {
    try {
      final response = await _dio.get('/api/dealer/list', queryParameters: {
        'page': page,
        'limit': limit,
        if (level != null) 'level': level,
        if (isActive != null) 'isActive': isActive,
        if (isFlagged != null) 'isFlagged': isFlagged,
        if (isVerified != null) 'isVerified': isVerified,
      });
      if (response.data['success'] == true) {
        return DealerListResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Get All Dealers Error: $e');
      return null;
    }
  }

  Future<bool> updateDealerLevel(String dealerUid, {String? level, int? commissionPercent, double? bonusPercent, String? notes}) async {
    try {
      final response = await _dio.put('/api/dealer/level/$dealerUid', data: {
        if (level != null) 'level': level,
        if (commissionPercent != null) 'commissionPercent': commissionPercent,
        if (bonusPercent != null) 'bonusPercent': bonusPercent,
        if (notes != null) 'notes': notes,
      });
      return response.data['success'] == true;
    } catch (e) {
      debugPrint('Update Dealer Level Error: $e');
      return false;
    }
  }

  Future<bool> toggleDealerStatus(String dealerUid, bool isActive, {String? notes}) async {
    try {
      final response = await _dio.put('/api/dealer/status/$dealerUid', data: {
        'isActive': isActive,
        if (notes != null) 'notes': notes,
      });
      return response.data['success'] == true;
    } catch (e) {
      debugPrint('Toggle Dealer Status Error: $e');
      return false;
    }
  }

  Future<bool> creditDealerWallet(String dealerUid, int amount, {String? reason, String? description}) async {
    try {
      final response = await _dio.post('/api/dealer/wallet/credit', data: {
        'dealerUid': dealerUid,
        'amount': amount,
        if (reason != null) 'reason': reason,
        if (description != null) 'description': description,
      });
      return response.data['success'] == true;
    } catch (e) {
      debugPrint('Credit Dealer Wallet Error: $e');
      return false;
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
}