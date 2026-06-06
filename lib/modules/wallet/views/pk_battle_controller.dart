import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/pk_battle_model.dart';
import '../../room/controllers/live_room_controller.dart';

class PkBattleController extends GetxController {
  final activeBattle = Rxn<PkBattleModel>();
  LiveRoomController? _roomController;

  @override
  void onInit() {
    super.onInit();
    _initSocketListeners();
  }

  void _initSocketListeners() {
    if (Get.isRegistered<LiveRoomController>()) {
      _roomController = Get.find<LiveRoomController>();
      final socket = _roomController?.socket;

      if (socket != null) {
        socket.on('pk_started', _onPkStarted);
        socket.on('pk_update', _onPkUpdate);
        socket.on('pk_ended', _onPkEnded);
      }
    }
  }

  void _onPkStarted(dynamic data) {
    activeBattle.value = PkBattleModel(
      battleId: data['battleId'],
      host1Id: data['host1Id'],
      host1Name: data['host1Name'],
      host1Avatar: data['host1Avatar'],
      host2Id: data['host2Id'],
      host2Name: data['host2Name'],
      host2Avatar: data['host2Avatar'],
      remainingSeconds: data['duration'] ?? 180,
      host1Score: 0,
      host2Score: 0,
    );
    Get.snackbar('⚔️ PK Started', 'The battle has begun!',
        backgroundColor: Colors.orangeAccent, colorText: Colors.white);
  }

  void _onPkUpdate(dynamic data) {
    if (activeBattle.value != null) {
      activeBattle.value = activeBattle.value!.copyWith(
        remainingSeconds: data['remainingSeconds'],
        host1Score: data['host1Score'],
        host2Score: data['host2Score'],
      );
    }
  }

  void _onPkEnded(dynamic data) {
    if (activeBattle.value != null) {
      activeBattle.value =
          activeBattle.value!.copyWith(isActive: false, remainingSeconds: 0);
      final winnerName = data['winnerName'] ?? 'Tie';
      Get.snackbar('🏁 PK Ended', 'Winner: $winnerName!',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  // Action triggered by the actual Gifts UI
  void sendGiftToHost(int hostNumber, int giftValue) {
    if (activeBattle.value == null || !activeBattle.value!.isActive) return;

    _roomController?.socket?.emit('pk_send_gift', {
      'battleId': activeBattle.value!.battleId,
      'hostNumber': hostNumber,
      'giftValue': giftValue,
    });
  }

  // Start request
  void requestStartPk(String opponentRoomId) {
    _roomController?.socket
        ?.emit('request_pk', {'targetRoomId': opponentRoomId});
  }
}
