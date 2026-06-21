// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/admin/presentation/repositories/admin_repository.dart
// ARVIND PARTY - ADMIN REPOSITORY
// ═══════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../../core/constants/env_config.dart';
import '../../../../core/services/auth_session_manager.dart';
import '../../../../core/utils/api_exception.dart';
import '../../../../core/constants/api_constants.dart';

class AdminRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: EnvConfig.plainApiBaseUrl));

  String? _getToken() {
    try {
      return Get.find<AuthSessionManager>().token.value;
    } catch (_) {
      return null;
    }
  }

  Options _authOptions() => Options(headers: {
        if (_getToken() != null) 'Authorization': 'Bearer ${_getToken()}',
      });

  /// Get admin dashboard stats
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _dio.get(ApiConstants.adminStats, options: _authOptions());
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) return data['data'] as Map<String, dynamic>;
      throw ApiException(message: data['message'] ?? 'Failed to fetch stats');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Get all users
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final response = await _dio.get(ApiConstants.adminUsers, options: _authOptions());
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final users = data['data'] as List<dynamic>? ?? [];
        return users.cast<Map<String, dynamic>>();
      }
      throw ApiException(message: data['message'] ?? 'Failed to fetch users');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Toggle user block/unblock
  Future<Map<String, dynamic>> toggleBlock(String userId) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.adminUserBlock}/$userId',
        options: _authOptions(),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Generate coins for a user
  Future<Map<String, dynamic>> generateCoins(String uid, int amount, String reason) async {
    try {
      final response = await _dio.post(
        ApiConstants.adminCoinsGenerate,
        data: {'uid': uid, 'amount': amount, 'reason': reason},
        options: _authOptions(),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Deduct coins from a user
  Future<Map<String, dynamic>> deductCoins(String uid, int amount, String reason) async {
    try {
      final response = await _dio.post(
        ApiConstants.adminCoinsDeduct,
        data: {'uid': uid, 'amount': amount, 'reason': reason},
        options: _authOptions(),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Get pending withdrawals
  Future<List<Map<String, dynamic>>> getWithdrawals() async {
    try {
      final response = await _dio.get(ApiConstants.adminWithdrawalsPending, options: _authOptions());
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final withdrawals = data['data'] as List<dynamic>? ?? [];
        return withdrawals.cast<Map<String, dynamic>>();
      }
      throw ApiException(message: data['message'] ?? 'Failed to fetch withdrawals');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Approve or reject a withdrawal
  Future<Map<String, dynamic>> processWithdrawal(String id, String status) async {
    try {
      final endpoint = status == 'approved'
          ? '${ApiConstants.adminWithdrawalApprove}/$id'
          : '${ApiConstants.adminWithdrawalReject}/$id';
      final response = await _dio.post(endpoint, options: _authOptions());
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Send reward to a user
  Future<Map<String, dynamic>> sendReward(Map<String, dynamic> rewardData) async {
    try {
      final response = await _dio.post(
        ApiConstants.adminRewardSend,
        data: rewardData,
        options: _authOptions(),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }
}