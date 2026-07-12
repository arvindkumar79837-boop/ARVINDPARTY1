// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/lucky_draw/presentation/controllers/lucky_draw_controller.dart
// ARVIND PARTY - LUCKY DRAW CONTROLLER WITH REAL-TIME REWARD CONFIG
// ═══════════════════════════════════════════════════════════════════════════

import 'package:arvind_party/core/services/api_service.dart';
import 'package:arvind_party/core/socket/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../repositories/lucky_draw_repository.dart';

class LuckyDrawController extends GetxController {
  final LuckyDrawRepository _repo = LuckyDrawRepository();
  final SocketService _socketService = Get.find<SocketService>();

  // State variables
  final isLoading = false.obs;
  final isSpinning = false.obs;
  final rewards = <Map<String, dynamic>>[].obs;
  final activeConfig = Rxn<Map<String, dynamic>>();
  final prize = Rxn<Map<String, dynamic>>();
  final newBalance = 0.obs;
  final lastWinAmount = 0.obs;
  final errorMessage = RxString('');
  final configVersion = RxString('');

  // Real-time config tracking
  final currentSpinCost = 100.obs;
  final currentJackpotEnabled = false.obs;
  final currentJackpotPool = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadRewards();
    setupSocketListeners();
    _repo.joinGameRoom('lucky_spin');
    _repo.requestActiveConfig('lucky_spin');
  }

  @override
  void onClose() {
    _repo.leaveGameRoom('lucky_spin');
    _repo.removeSocketListeners();
    _socketService.off('active_config');
    super.onClose();
  }

  /// Load available lucky spin configurations
  Future<void> loadRewards() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final fetched = await _repo.fetchRewards();
      rewards.assignAll(fetched);
      
      // Load active config
      if (fetched.isNotEmpty) {
        final active = fetched.first;
        activeConfig.value = active;
        currentSpinCost.value = active['spinCostCoins'] ?? 100;
        currentJackpotEnabled.value = active['jackpotEnabled'] ?? false;
        currentJackpotPool.value = active['jackpotCurrentPool'] ?? 0;
        configVersion.value = active['version'] ?? '1.0.0';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load rewards: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Spin the wheel with real-time config
  Future<void> spin() async {
    if (isSpinning.value) return;
    
    // Check balance
    final balance = await _checkBalance();
    if (balance < currentSpinCost.value) {
      errorMessage.value = 'Insufficient coins. You need ${currentSpinCost.value} coins to spin.';
      return;
    }

    try {
      isSpinning.value = true;
      prize.value = null;
      errorMessage.value = '';

      final result = await _repo.spin();
      
      if (result['reward'] != null) {
        prize.value = result['reward'] as Map<String, dynamic>;
        lastWinAmount.value = prize.value?['prize_value'] ?? 0;
        
        // Update balance
        newBalance.value = result['newBalance'] ?? 0;
        
        // Check for jackpot
        if (result['jackpot_hit'] == true) {
          currentJackpotPool.value = 0;
          Get.snackbar(
            '🎰 JACKPOT!!! 🎰',
            'You won ${prize.value?['prize_name'] ?? 'JACKPOT'}!',
            backgroundColor: Colors.yellow,
            colorText: Colors.black,
            duration: const Duration(seconds: 4),
          );
        } else {
          Get.snackbar(
            'Congratulations!',
            'You won ${prize.value?['prize_name'] ?? 'a prize'}!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      } else {
        prize.value = {
          'name': result['message'] ?? 'Try Again!', 
          'type': 'info', 
          'value': 0,
          'prize_name': 'Better luck next time'
        };
      }

      // Refresh config in case it was updated
      loadRewards();
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      errorMessage.value = msg;
      Get.snackbar('Spin Failed', msg, backgroundColor: Colors.red);
    } finally {
      isSpinning.value = false;
    }
  }

  /// Setup real-time socket listeners
  void setupSocketListeners() {
    _repo.listenToSocketEvents(
      onConfigUpdated: (data) {
        configVersion.value = data['version'] ?? configVersion.value;
        Get.snackbar(
          '🎮 Prize Pool Updated',
          'New configuration deployed! Check out the latest rewards.',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        loadRewards();
      },
      onConfigDeployed: (data) {
        configVersion.value = data['version'] ?? configVersion.value;
        Get.snackbar(
          '⚡ Live Configuration',
          'New reward configuration is now active!',
          backgroundColor: Colors.purple,
          colorText: Colors.white,
        );
        loadRewards();
      },
      onJackpotHit: (data) {
        Get.snackbar(
          '🎰 JACKPOT HIT! 🎰',
          'Someone just won ${data['prize_name'] ?? 'JACKPOT'}!',
          backgroundColor: Colors.yellow,
          colorText: Colors.black,
          duration: const Duration(seconds: 4),
        );
      },
      onError: (data) {
        errorMessage.value = data['message'] ?? 'An error occurred';
      },
    );
  }

  /// Check user balance
  Future<int> _checkBalance() async {
    try {
      final apiService = Get.find<ApiService>();
      final response = await apiService.get('/wallet/balance');
      if (response['success'] == true) {
        return response['data']['coins'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Clear result
  void clearResult() {
    prize.value = null;
    errorMessage.value = '';
    lastWinAmount.value = 0;
  }

  /// Refresh all data
  @override
  Future<void> refresh() async {
    await loadRewards();
    _repo.requestActiveConfig('lucky_spin');
  }
}