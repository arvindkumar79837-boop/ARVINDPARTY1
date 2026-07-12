// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/pk_battle/presentation/controllers/pk_battle_controller.dart
// ARVIND PARTY - PK BATTLE CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../../../../core/socket/socket_service.dart';
import '../repositories/pk_battle_repository.dart';

class PkBattleController extends GetxController {
  final isLoading = false.obs;
  final battleRequest = Rxn<Map<String, dynamic>>();
  final liveBattle = Rxn<Map<String, dynamic>>();
  final errorMessage = RxString('');

  final PkBattleRepository _repo = PkBattleRepository();
  final SocketService _socket = Get.find<SocketService>();

  @override
  void onInit() {
    super.onInit();
    _socket.on('pk_request', _handlePkRequest);
    _socket.on('pk_start', _handlePkStart);
    _socket.on('pk_end', _handlePkEnd);
    _socket.on('pk_score_update', _handlePkScoreUpdate);
  }

  @override
  void onClose() {
    _socket.off('pk_request');
    _socket.off('pk_start');
    _socket.off('pk_end');
    _socket.off('pk_score_update');
    super.onClose();
  }

  void _handlePkRequest(dynamic data) {
    battleRequest.value = data as Map<String, dynamic>;
  }

  void _handlePkStart(dynamic data) {
    liveBattle.value = data as Map<String, dynamic>;
    battleRequest.value = null; // Clear pending request
  }

  void _handlePkEnd(dynamic data) {
    liveBattle.value = null;
    // You can show a dialog with the results
    Get.snackbar('PK Battle Ended', 'Winner is ${data['winnerId']}');
  }

  void _handlePkScoreUpdate(dynamic data) {
    if (liveBattle.value != null) {
      liveBattle.update((val) {
        val!['hostScore'] = data['hostScore'];
        val['opponentScore'] = data['opponentScore'];
      });
    }
  }

  /// Request a PK battle
  Future<void> requestPkBattle(
      {required String opponentId,
      required String roomId,
      int? durationMinutes}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await _repo.requestBattle(
          opponentId: opponentId,
          roomId: roomId,
          durationMinutes: durationMinutes);
      if (result['success'] == true) {
        // The backend will emit a pk_request event to the opponent
        // The host will wait for the pk_start event
        Get.snackbar(
            'Success', result['message'] as String? ?? 'PK Battle request sent.');
      } else {
        errorMessage.value =
            result['message'] as String? ?? 'Failed to send PK Battle request.';
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
        // The backend will emit a pk_start event to the room
      } else {
        errorMessage.value =
            result['message'] as String? ?? 'Failed to accept PK Battle.';
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
        // The backend will emit a pk_end event to the room
      } else {
        errorMessage.value =
            result['message'] as String? ?? 'Failed to end PK Battle.';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  /// Update score during a live PK battle
  void updateScore(String battleId, int score, String supportedUserId) {
    _socket.emit('pk_update_score', {
      'battleId': battleId,
      'score': score,
      'supportedUserId': supportedUserId,
    });
  }

  /// Reset battle state
  void resetBattleState() {
    battleRequest.value = null;
    liveBattle.value = null;
    errorMessage.value = '';
    isLoading.value = false;
  }
}
