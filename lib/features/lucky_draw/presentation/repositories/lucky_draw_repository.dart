// ═══════════════════════════════════════════════════════════════════════════
// REPOSITORY: LuckyDrawRepository — API calls for Lucky Spin
// ═══════════════════════════════════════════════════════════════════════════

import 'package:arvind_party/core/services/api_service.dart';
import 'package:arvind_party/core/services/socket_service.dart';
import 'package:get/get.dart';

class LuckyDrawRepository {
  final ApiService _apiService = Get.find<ApiService>();
  final SocketService _socketService = Get.find<SocketService>();

  /// Fetch available lucky spin configurations
  Future<List<Map<String, dynamic>>> fetchRewards() async {
    try {
      final response = await _apiService.get('/lucky-draw');
      if (response['success'] == true) {
        return List<Map<String, dynamic>>.from(response['data'] ?? []);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch lucky draws: $e');
    }
  }

  /// Spin the wheel
  Future<Map<String, dynamic>> spin() async {
    try {
      final response = await _apiService.post('/lucky-draw/spin', body: {});
      if (response['success'] == true && response['data'] != null) {
        return response['data'];
      }
      throw Exception(response['message'] ?? 'Spin failed');
    } catch (e) {
      throw Exception('Spin failed: $e');
    }
  }

  /// Get single lucky draw by ID
  Future<Map<String, dynamic>> getLuckyDrawById(String drawId) async {
    try {
      final response = await _apiService.get('/lucky-draw/$drawId');
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      }
      throw Exception(response['message'] ?? 'Lucky draw not found');
    } catch (e) {
      throw Exception('Failed to fetch lucky draw: $e');
    }
  }

  /// Join game room for real-time updates
  void joinGameRoom(String gameType) {
    _socketService.emit('join_game_room', gameType);
  }

  /// Leave game room
  void leaveGameRoom(String gameType) {
    _socketService.emit('leave_game_room', gameType);
  }

  /// Request active config
  void requestActiveConfig(String gameType) {
    _socketService.emit('get_active_config', gameType);
  }

  /// Listen to socket updates
  void listenToSocketEvents({
    Function(Map<String, dynamic>)? onConfigUpdated,
    Function(Map<String, dynamic>)? onConfigDeployed,
    Function(Map<String, dynamic>)? onJackpotHit,
    Function(Map<String, dynamic>)? onError,
  }) {
    _socketService.on('reward_config_updated', (data) {
      final event = Map<String, dynamic>.from(data);
      onConfigUpdated?.call(event);
    });

    _socketService.on('reward_config_deployed', (data) {
      final event = Map<String, dynamic>.from(data);
      onConfigDeployed?.call(event);
    });

    _socketService.on('jackpot_hit', (data) {
      final event = Map<String, dynamic>.from(data);
      onJackpotHit?.call(event);
    });

    _socketService.on('global_jackpot', (data) {
      final event = Map<String, dynamic>.from(data);
      onJackpotHit?.call(event);
    });

    _socketService.on('error', (data) {
      final event = Map<String, dynamic>.from(data);
      onError?.call(event);
    });
  }

  /// Remove socket listeners
  void removeSocketListeners() {
    _socketService.off('reward_config_updated');
    _socketService.off('reward_config_deployed');
    _socketService.off('jackpot_hit');
    _socketService.off('global_jackpot');
    _socketService.off('error');
  }
}