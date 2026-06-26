import 'package:get/get.dart';
import 'package:arvind_party/core/services/api_service.dart';
import 'package:arvind_party/core/services/socket_service.dart';
import 'package:arvind_party/features/games/models/webview_game_model.dart';

class GameRepository {
  final ApiService _apiService = Get.find<ApiService>();
  final SocketService _socketService = Get.find<SocketService>();

  Future<List<WebViewGameModel>> getActiveGames() async {
    try {
      final response = await _apiService.get('/api/games/active');
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> gamesList = response['data'];
        return gamesList.map((game) => WebViewGameModel.fromJson(game)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch active games: $e');
    }
  }

  Future<WebViewGameModel> getGameById(String gameId) async {
    try {
      final response = await _apiService.get('/api/games/$gameId');
      if (response['success'] == true && response['data'] != null) {
        return WebViewGameModel.fromJson(response['data']);
      }
      throw Exception('Game not found');
    } catch (e) {
      throw Exception('Failed to fetch game: $e');
    }
  }

  Future<GameSessionModel> startGameSession(String gameId, int betAmount) async {
    try {
      final response = await _apiService.post('/api/games/start-session', body: {
        'gameId': gameId,
        'betAmount': betAmount,
      });

      if (response['success'] == true) {
        return GameSessionModel.fromJson(response);
      }
      throw Exception(response['message'] ?? 'Failed to start game session');
    } catch (e) {
      throw Exception('Failed to start game session: $e');
    }
  }

  Future<Map<String, dynamic>> endGameSession(String sessionId, int winAmount) async {
    try {
      final response = await _apiService.post('/api/games/end-session', body: {
        'sessionId': sessionId,
        'winAmount': winAmount,
      });

      if (response['success'] == true) {
        return response;
      }
      throw Exception(response['message'] ?? 'Failed to end game session');
    } catch (e) {
      throw Exception('Failed to end game session: $e');
    }
  }

  Future<List<GameLeaderboardEntry>> getLeaderboard({String period = 'weekly', String? gameId, int limit = 50}) async {
    try {
      final queryParams = <String, String>{
        'period': period,
        'limit': limit.toString(),
      };
      if (gameId != null) {
        queryParams['gameId'] = gameId;
      }

      const uri = '/api/games/leaderboard';
      final response = await _apiService.get(uri);

      if (response['success'] == true && response['leaderboard'] != null) {
        final List<dynamic> leaderboardList = response['leaderboard'];
        return leaderboardList.map((entry) => GameLeaderboardEntry.fromJson(entry)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch leaderboard: $e');
    }
  }

  void joinGameRoom(String gameId) {
    _socketService.emit('join_game_room', gameId);
  }

  void leaveGameRoom(String gameId) {
    _socketService.emit('leave_game_room', gameId);
  }

  void sendGameAction(String sessionId, String action, Map<String, dynamic> payload) {
    _socketService.emit('game_action', {
      'sessionId': sessionId,
      'action': action,
      'payload': payload,
    });
  }

  void sendGameResult(String sessionId, int winAmount, Map<String, dynamic> resultData) {
    _socketService.emit('game_result', {
      'sessionId': sessionId,
      'winAmount': winAmount,
      'resultData': resultData,
    });
  }

  void onGameUpdate(Function(dynamic) callback) {
    _socketService.on('game_update', callback);
  }

  void onGameCompleted(Function(dynamic) callback) {
    _socketService.on('game_completed', callback);
  }

  void onGameEnded(Function(dynamic) callback) {
    _socketService.on('game_ended', callback);
  }

  void onGameError(Function(dynamic) callback) {
    _socketService.on('error', callback);
  }

  void dispose() {
    // Clean up socket listeners if needed
  }
}