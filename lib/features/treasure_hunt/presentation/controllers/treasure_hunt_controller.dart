// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/treasure_hunt/presentation/controllers/treasure_hunt_controller.dart
// ARVIND PARTY - TREASURE HUNT CONTROLLER WITH REAL-TIME REWARD CONFIG
// ═══════════════════════════════════════════════════════════════════════════

import 'package:arvind_party/core/socket/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../repositories/treasure_hunt_repository.dart';

class TreasureHuntController extends GetxController {
  final TreasureHuntRepository _repo = TreasureHuntRepository();
  final SocketService _socketService = Get.find<SocketService>();

  // State variables
  final isLoading = false.obs;
  final isCollectingKey = false.obs;
  final activeTreasureHunt = Rxn<Map<String, dynamic>>();
  final myTreasureHunts = <Map<String, dynamic>>[].obs;
  final keysCollected = 0.obs;
  final keysRequired = 5.obs;
  final isTreasureFound = false.obs;
  final hasKey = false.obs;
  final errorMessage = RxString('');
  final huntStatus = RxString('');

  @override
  void onInit() {
    super.onInit();
    setupSocketListeners();
  }

  @override
  void onClose() {
    _repo.leaveGameRoom('treasure_hunt');
    _repo.removeSocketListeners();
    super.onClose();
  }

  /// Load active treasure hunt for a specific room
  Future<void> loadActiveTreasureHunt(String roomId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final hunt = await _repo.getActiveTreasureHunt(roomId);
      activeTreasureHunt.value = hunt;
      
      keysRequired.value = hunt['keysRequired'] ?? 5;
      keysCollected.value = hunt['keysCollected'] ?? 0;
      isTreasureFound.value = hunt['isFound'] ?? false;
      hasKey.value = hunt['hasKey'] ?? false;
      huntStatus.value = isTreasureFound.value ? 'FOUND' : (hunt['status'] ?? 'ACTIVE');
      
      _repo.joinGameRoom('treasure_hunt');
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      activeTreasureHunt.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Collect a treasure key
  Future<void> collectKey() async {
    if (isCollectingKey.value) return;
    if (hasKey.value) {
      errorMessage.value = 'You have already collected a key';
      return;
    }
    if (activeTreasureHunt.value == null) {
      errorMessage.value = 'No active treasure hunt';
      return;
    }

    try {
      isCollectingKey.value = true;
      errorMessage.value = '';
      
      final result = await _repo.collectKey(activeTreasureHunt.value!['_id']);
      
      if (result['success'] == true) {
        hasKey.value = true;
        keysCollected.value = result['data']['keysCollected'] ?? keysCollected.value + 1;
        
        if (result['data']['isFound'] == true) {
          isTreasureFound.value = true;
          huntStatus.value = 'FOUND';
          
          // Show celebration
          Get.dialog(
            AlertDialog(
              icon: const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
              title: const Text(
                '🎉 TREASURE FOUND! 🎉',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              content: const Text(
                'Congratulations! You found the treasure!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('AMAZING!'),
                ),
              ],
            ),
            barrierDismissible: false,
          );
        } else {
          Get.snackbar(
            '🔑 Key Collected!',
            '${keysCollected.value} / ${keysRequired.value} keys collected',
            backgroundColor: Colors.blue,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      errorMessage.value = msg;
      Get.snackbar('Collection Failed', msg, backgroundColor: Colors.red);
    } finally {
      isCollectingKey.value = false;
    }
  }

  /// Load my treasure hunts history
  Future<void> loadMyTreasureHunts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final hunts = await _repo.getMyTreasureHunts();
      myTreasureHunts.assignAll(hunts);
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Setup real-time socket listeners
  void setupSocketListeners() {
    _repo.listenToSocketEvents(
      onTreasureFound: (data) {
        isTreasureFound.value = true;
        huntStatus.value = 'FOUND';
        
        Get.snackbar(
          '🏴‍☠️ Treasure Found!',
          'Someone found the treasure in this hunt!',
          backgroundColor: Colors.amber,
          colorText: Colors.black,
          duration: const Duration(seconds: 5),
        );
      },
      onKeyCollected: (data) {
        keysCollected.value = data['keysCollected'] ?? keysCollected.value;
        
        // Always show notification - backend handles user-specific filtering
        Get.snackbar(
          '🔑 Key Collected!',
          '${keysCollected.value} / ${keysRequired.value} keys collected',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
      },
      onConfigUpdated: (data) {
        Get.snackbar(
          '🎮 Event Updated',
          'Treasure hunt configuration has been updated',
          backgroundColor: Colors.purple,
          colorText: Colors.white,
        );
        
        // Refresh current hunt
        if (activeTreasureHunt.value != null) {
          loadActiveTreasureHunt(activeTreasureHunt.value!['roomId'] ?? '');
        }
      },
      onError: (data) {
        errorMessage.value = data['message'] ?? 'An error occurred';
      },
    );
  }

  /// Clear current hunt
  void clearHunt() {
    activeTreasureHunt.value = null;
    keysCollected.value = 0;
    keysRequired.value = 5;
    isTreasureFound.value = false;
    hasKey.value = false;
    errorMessage.value = '';
    huntStatus.value = '';
  }

  /// Refresh current hunt data
  @override
  Future<void> refresh() async {
    if (activeTreasureHunt.value != null) {
      final roomId = activeTreasureHunt.value!['roomId'] ?? '';
      await loadActiveTreasureHunt(roomId);
    }
  }
}