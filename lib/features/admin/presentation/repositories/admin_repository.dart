// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/admin/presentation/repositories/admin_repository.dart
// ARVIND PARTY - ADMIN REPOSITORY
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/utils/api_exception.dart';

class AdminRepository {
  final _api = Get.find<ApiService>();

  /// Get admin dashboard stats
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _api.get(ApiConstants.adminStats);
      final data = response as Map<String, dynamic>;
      if (data['success'] == true) return data['data'] as Map<String, dynamic>;
      throw ApiException(message: data['message'] ?? 'Failed to fetch stats');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  /// Get all users
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final response = await _api.get(ApiConstants.adminUsers);
      final data = response as Map<String, dynamic>;
      if (data['success'] == true) {
        final users = data['data'] as List<dynamic>? ?? [];
        return users.cast<Map<String, dynamic>>();
      }
      throw ApiException(message: data['message'] ?? 'Failed to fetch users');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  /// Toggle user block/unblock
  Future<Map<String, dynamic>> toggleBlock(String userId) async {
    try {
      final response = await _api.post('${ApiConstants.adminUserBlock}/$userId');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  /// Generate coins for a user
  Future<Map<String, dynamic>> generateCoins(String uid, int amount, String reason) async {
    try {
      final response = await _api.post(
        ApiConstants.adminCoinsGenerate,
        body: {'uid': uid, 'amount': amount, 'reason': reason},
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  /// Deduct coins from a user
  Future<Map<String, dynamic>> deductCoins(String uid, int amount, String reason) async {
    try {
      final response = await _api.post(
        ApiConstants.adminCoinsDeduct,
        body: {'uid': uid, 'amount': amount, 'reason': reason},
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  /// Get pending withdrawals
  Future<List<Map<String, dynamic>>> getWithdrawals() async {
    try {
      final response = await _api.get(ApiConstants.adminWithdrawalsPending);
      final data = response as Map<String, dynamic>;
      if (data['success'] == true) {
        final withdrawals = data['data'] as List<dynamic>? ?? [];
        return withdrawals.cast<Map<String, dynamic>>();
      }
      throw ApiException(message: data['message'] ?? 'Failed to fetch withdrawals');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  /// Approve or reject a withdrawal
  Future<Map<String, dynamic>> processWithdrawal(String id, String status) async {
    try {
      final endpoint = status == 'approved'
          ? '${ApiConstants.adminWithdrawalApprove}/$id'
          : '${ApiConstants.adminWithdrawalReject}/$id';
      final response = await _api.post(endpoint);
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  /// Send reward to a user
  Future<Map<String, dynamic>> sendReward(Map<String, dynamic> rewardData) async {
    try {
      final response = await _api.post(
        ApiConstants.adminRewardSend,
        body: rewardData,
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}