// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/games/presentation/controllers/games_controller.dart
// ARVIND PARTY - GAMES CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';

import '../../models/webview_game_model.dart';
import '../repositories/games_repository.dart';

class GamesController extends GetxController {
  final isLoading = false.obs;
  final isPlaying = false.obs;
  final lastReward = Rxn<Map<String, dynamic>>();
  final balance = Rxn<Map<String, dynamic>>();
  final leaderboard = <GameLeaderboardEntry>[].obs;
  final errorMessage = RxString('');

  final GamesRepository _repo = GamesRepository();

  @override
  void onInit() {
    super.onInit();
    loadLeaderboard();
  }

  /// Load the weekly game leaderboard
  Future<void> loadLeaderboard() async {
    try {
      final list = await _repo.getLeaderboard();
      leaderboard.assignAll(list);
    } catch (e) {
    }
  }

  /// Play Lucky Wheel (cost: 50 coins)
  Future<void> playLuckyWheel() async {
    if (isPlaying.value) return;
    try {
      isPlaying.value = true;
      errorMessage.value = '';
      lastReward.value = null;

      final result = await _repo.playLuckyWheel();
      if (result['success'] == true) {
        lastReward.value = result['reward'] as Map<String, dynamic>?;
        balance.value = result['balance'] as Map<String, dynamic>?;
      } else {
        errorMessage.value = result['error'] as String? ?? 'Spin failed';
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isPlaying.value = false;
    }
  }

  /// Play Scratch Card (cost: 20 coins)
  Future<void> playScratchCard() async {
    if (isPlaying.value) return;
    try {
      isPlaying.value = true;
      errorMessage.value = '';
      lastReward.value = null;

      final result = await _repo.playScratchCard();
      if (result['success'] == true) {
        lastReward.value = result['reward'] as Map<String, dynamic>?;
        balance.value = result['balance'] as Map<String, dynamic>?;
      } else {
        errorMessage.value = result['error'] as String? ?? 'Scratch failed';
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isPlaying.value = false;
    }
  }

  void clearResult() {
    lastReward.value = null;
    errorMessage.value = '';
  }

  @override
  void onClose() {
    super.onClose();
  }
}