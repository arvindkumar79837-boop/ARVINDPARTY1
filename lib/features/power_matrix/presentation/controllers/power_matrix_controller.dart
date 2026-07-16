// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/power_matrix/presentation/controllers/power_matrix_controller.dart
// ARVIND PARTY - POWER MATRIX CONTROLLER (GetX)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/api_service.dart';
// repository import removed - using ApiService directly
import '../../models/power_matrix_model.dart';

class PowerMatrixController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  // ─── Power Matrix State ──────────────────────────────────────
  final Rx<PowerMatrix?> powerMatrix = Rxn<PowerMatrix?>();
  final RxList<PowerMatrixRule> rules = <PowerMatrixRule>[].obs;
  final Rx<PowerMatrixGlobalSettings> globalSettings = PowerMatrixGlobalSettings(
    ownerCanOverrideAll: true,
    adminCanOverrideVip: true,
    svipImmunityLevel: 10,
    vipImmunityLevel: 8,
    levelDifferenceRequired: 2,
  ).obs;
  final RxBool isActive = true.obs;
  final RxInt version = 1.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // ─── Power Check State ──────────────────────────────────────
  final Rx<PowerCheckResult?> lastCheckResult = Rxn<PowerCheckResult?>();
  final RxString checkTargetUserId = ''.obs;
  final RxString checkAction = 'mute'.obs;

  // ─── History State ──────────────────────────────────────────
  final RxList<PowerMatrixHistory> history = <PowerMatrixHistory>[].obs;
  final RxBool isLoadingHistory = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPowerMatrix();
  }

  Future<void> fetchPowerMatrix() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _api.get('/api/power-matrix');
      if (response != null && response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>? ?? response;
        if (data is Map<String, dynamic>) {
          powerMatrix.value = PowerMatrix.fromJson(data);
          if (data['rules'] != null) {
            rules.assignAll((data['rules'] as List).map((r) => PowerMatrixRule.fromJson(r)));
          }
          if (data['globalSettings'] != null) {
            globalSettings.value = PowerMatrixGlobalSettings.fromJson(data['globalSettings']);
          }
          isActive.value = data['isActive'] ?? true;
          version.value = data['version'] ?? 1;
        }
      } else {
        errorMessage.value = 'Failed to load power matrix configuration.';
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updatePowerMatrix() async {
    if (rules.isEmpty) {
      Get.snackbar('Validation Error', 'Rules cannot be empty.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _api.post('/api/power-matrix/update', body: {'rules': rules.map((r) => r.toJson()).toList(), 'globalSettings': globalSettings.value.toJson()});
      final success = response['success'] == true;
      if (success) {
        Get.snackbar('Success', 'Power matrix updated successfully.',
            backgroundColor: Colors.greenAccent, colorText: Colors.black);
        await fetchPowerMatrix();
        return true;
      } else {
        errorMessage.value = 'Failed to update power matrix.';
        Get.snackbar('Error', 'Failed to update power matrix.',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      Get.snackbar('Error', 'Update failed: ${e.toString()}',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> resetPowerMatrix() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _api.post('/api/power-matrix/reset');
      final success = response['success'] == true;
      if (success) {
        Get.snackbar('Success', 'Power matrix reset to defaults.',
            backgroundColor: Colors.greenAccent, colorText: Colors.black);
        await fetchPowerMatrix();
        return true;
      } else {
        errorMessage.value = 'Failed to reset power matrix.';
        Get.snackbar('Error', 'Failed to reset power matrix.',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      Get.snackbar('Error', 'Reset failed: ${e.toString()}',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkUserPower(String targetUserId, String action) async {
    if (targetUserId.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Target user ID is required.',
          backgroundColor: Colors.orangeAccent, colorText: Colors.black);
      return;
    }

    isLoading.value = true;
    lastCheckResult.value = null;
    try {
      final response = await _api.get('/api/power-matrix/check', queryParams: {'userId': targetUserId, 'action': action});
      if (response != null && response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>? ?? response;
        lastCheckResult.value = PowerCheckResult.fromJson(data);
      } else {
        Get.snackbar('Error', 'Failed to check power.',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Check failed: ${e.toString()}',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchHistory() async {
    isLoadingHistory.value = true;
    try {
      final response = await _api.get('/api/power-matrix/history');
      if (response != null && response['success'] == true) {
        final data = response['data'] as List<dynamic>? ?? [];
        history.assignAll(data.map((h) => PowerMatrixHistory.fromJson(h)).toList());
      }
    } catch (e) {
    } finally {
      isLoadingHistory.value = false;
    }
  }

  void updateRule(PowerMatrixRule updatedRule) {
    final idx = rules.indexWhere((r) => r.level == updatedRule.level);
    if (idx != -1) {
      rules[idx] = updatedRule;
    } else {
      rules.add(updatedRule);
    }
    rules.sort((a, b) => b.level.compareTo(a.level));
  }

  void updateGlobalSettings(PowerMatrixGlobalSettings settings) {
    globalSettings.value = settings;
  }

  PowerMatrixRule? getRuleForLevel(int level) {
    try {
      return rules.firstWhere((rule) => rule.level == level);
    } catch (e) {
      return null;
    }
  }

  void removeRule(int level) {
    rules.removeWhere((r) => r.level == level);
  }

  List<PowerMatrixRule> getActiveRules() {
    return rules.where((rule) => rule.level > 0).toList();
  }

  List<int> getAvailableLevels() {
    return List.generate(50, (index) => index + 1);
  }

  String getPowerCheckDescription(PowerCheckResult result) {
    if (result.allowed) {
      return '${result.action.toUpperCase()} ALLOWED\nActor Level: ${result.actorLevel} (${result.actorRole})\nTarget Level: ${result.targetLevel} (${result.targetRole})\nReason: ${result.reason}';
    } else {
      return '${result.action.toUpperCase()} DENIED\nActor Level: ${result.actorLevel} (${result.actorRole})\nTarget Level: ${result.targetLevel} (${result.targetRole})\nReason: ${result.reason}';
    }
  }

  Color getPowerCheckColor(PowerCheckResult result) {
    return result.allowed ? Colors.green : Colors.red;
  }

  @override
  void onClose() {
    super.onClose();
  }
}