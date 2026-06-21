// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/pk_battle/presentation/controllers/pk_battle_controller.dart
// ARVIND PARTY - PK BATTLE CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../repositories/pk_battle_repository.dart';

class PkBattleController extends GetxController {
  final isLoading = false.obs;
  final battleRequest = Rxn<Map<String, dynamic>>();
  final liveBattle = Rxn<Map<String, dynamic>>();
  final errorMessage = RxString('');

  final PkBattleRepository _repo = PkBattleRepository();

  /// Request a PK battle
  Future<void> requestPkBattle({required String opponentId, required String roomId, int? durationMinutes}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await _repo.requestBattle(opponentId: opponentId, roomId: roomId, durationMinutes: durationMinutes);
      if (result['success'] == true) {
        battleRequest.value = result['data'] as Map<String, dynamic>?;
        Get.snackbar('Success', result['message'] as String? ?? 'PK Battle request sent.');
      } else {
        errorMessage.value = result['message'] as String? ?? 'Failed to send PK Battle request.';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  /// Accept a PK battle request
  Future<void> acceptPkBattle(String battleId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await _repo.acceptBattle(battleId);
      if (result['success'] == true) {
        liveBattle.value = result['data'] as Map<String, dynamic>?;
        Get.snackbar('Success', result['message'] as String? ?? 'PK Battle started!');
        battleRequest.value = null; // Clear pending request
      } else {
        errorMessage.value = result['message'] as String? ?? 'Failed to accept PK Battle.';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  /// End a live PK battle
  Future<void> endPkBattle(String battleId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await _repo.endBattle(battleId);
      if (result['success'] == true) {
        liveBattle.value = null; // Clear live battle
        Get.snackbar('Success', result['message'] as String? ?? 'PK Battle ended.');
      } else {
        errorMessage.value = result['message'] as String? ?? 'Failed to end PK Battle.';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('Error', errorMessage.value);
    }
    finally {
      isLoading.value = false;
    }
  }

  /// Reset battle state
  void resetBattleState() {
    battleRequest.value = null;
    liveBattle.value = null;
    errorMessage.value = '';
    isLoading.value = false;
  }
}
