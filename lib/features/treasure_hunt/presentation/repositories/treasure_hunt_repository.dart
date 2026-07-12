// ═══════════════════════════════════════════════════════════════════════════
// REPOSITORY: TreasureHuntRepository — API calls for Treasure Hunt
// ═══════════════════════════════════════════════════════════════════════════

import 'package:arvind_party/core/services/api_service.dart';
import 'package:arvind_party/core/socket/socket_service.dart';
import 'package:get/get.dart';

class TreasureHuntRepository {
  final ApiService _apiService = Get.find<ApiService>();
  final SocketService _socketService = Get.find<SocketService>();

  /// Get active treasure hunt for a room
  Future<Map<String, dynamic>> getActiveTreasureHunt(String roomId) async {
    try {
      final response = await _apiService.get('/treasure-hunt/active?roomId=$roomId');
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      }
      throw Exception(response['message'] ?? 'No active treasure hunt found');
    } catch (e) {
      throw Exception('Failed to fetch treasure hunt: $e');
    }
  }

  /// Collect a treasure key
  Future<Map<String, dynamic>> collectKey(String huntId) async {
    try {
      final response = await _apiService.post('/treasure-hunt/collect-key/$huntId', body: {});
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      }
      throw Exception(response['message'] ?? 'Failed to collect key');
    } catch (e) {
      throw Exception('Key collection failed: $e');
    }
  }

  /// Get user's active treasure hunts
  Future<List<Map<String, dynamic>>> getMyTreasureHunts() async {
    try {
      final response = await _apiService.get('/treasure-hunt/my-hunts');
      if (response['success'] == true) {
        return List<Map<String, dynamic>>.from(response['data'] ?? []);
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch treasure hunts: $e');
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

  /// Listen to socket updates
  void listenToSocketEvents({
    Function(Map<String, dynamic>)? onTreasureFound,
    Function(Map<String, dynamic>)? onKeyCollected,
    Function(Map<String, dynamic>)? onConfigUpdated,
    Function(Map<String, dynamic>)? onError,
  }) {
    _socketService.on('treasure_found', (data) {
      final event = Map<String, dynamic>.from(data);
      onTreasureFound?.call(event);
    });

    _socketService.on('key_collected', (data) {
      final event = Map<String, dynamic>.from(data);
      onKeyCollected?.call(event);
    });

    _socketService.on('reward_config_updated', (data) {
      final event = Map<String, dynamic>.from(data);
      onConfigUpdated?.call(event);
    });

    _socketService.on('error', (data) {
      final event = Map<String, dynamic>.from(data);
      onError?.call(event);
    });
  }

  /// Remove socket listeners
  void removeSocketListeners() {
    _socketService.off('treasure_found');
    _socketService.off('key_collected');
    _socketService.off('reward_config_updated');
    _socketService.off('error');
  }
}