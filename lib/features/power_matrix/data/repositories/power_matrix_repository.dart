// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/power_matrix/data/repositories/power_matrix_repository.dart
// ARVIND PARTY - POWER MATRIX REPOSITORY
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../../core/services/api_service.dart';
import '../../models/power_matrix_model.dart';

class PowerMatrixRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<PowerMatrix?> getPowerMatrix() async {
    try {
      final response = await _apiService.get('/rooms/power-matrix');
      if (response is Map && response['success'] == true) {
        return PowerMatrix.fromJson(Map<String, dynamic>.from(response['data']));
      }
      return null;
    } catch (e) {
      debugPrint('[PowerMatrixRepository] getPowerMatrix error: $e');
      return null;
    }
  }

  Future<bool> updatePowerMatrix(List<PowerMatrixRule> rules, PowerMatrixGlobalSettings settings) async {
    try {
      final response = await _apiService.put('/rooms/power-matrix', body: {
        'rules': rules.map((r) => r.toJson()).toList(),
        'globalSettings': settings.toJson(),
      });
      return response is Map && response['success'] == true;
    } catch (e) {
      debugPrint('[PowerMatrixRepository] updatePowerMatrix error: $e');
      return false;
    }
  }

  Future<bool> resetPowerMatrix() async {
    try {
      final response = await _apiService.post('/rooms/power-matrix/reset', body: {});
      return response is Map && response['success'] == true;
    } catch (e) {
      debugPrint('[PowerMatrixRepository] resetPowerMatrix error: $e');
      return false;
    }
  }

  Future<PowerCheckResult?> checkUserPower(String targetUserId, String action) async {
    try {
      final response = await _apiService.post('/rooms/check-power', body: {
        'targetUserId': targetUserId,
        'action': action,
      });
      if (response is Map && response['success'] == true) {
        return PowerCheckResult.fromJson(Map<String, dynamic>.from(response['data']));
      }
      return null;
    } catch (e) {
      debugPrint('[PowerMatrixRepository] checkUserPower error: $e');
      return null;
    }
  }

  Future<List<PowerMatrixHistory>?> getPowerMatrixHistory() async {
    try {
      final response = await _apiService.get('/rooms/power-matrix/history');
      if (response is Map && response['success'] == true) {
        final List<dynamic> historyList = response['data'] ?? [];
        return historyList
            .map((h) => PowerMatrixHistory.fromJson(Map<String, dynamic>.from(h)))
            .toList();
      }
      return null;
    } catch (e) {
      debugPrint('[PowerMatrixRepository] getPowerMatrixHistory error: $e');
      return null;
    }
  }
}