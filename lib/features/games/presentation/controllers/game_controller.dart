import 'package:get/get.dart';
import 'package:arvind_party/core/services/api_service.dart';
import 'package:arvind_party/core/services/socket_service.dart';
import '../repositories/game_repository.dart';
import '../../models/webview_game_model.dart';

class GameController extends GetxController {
  final GameRepository _repository = GameRepository();
  final ApiService _apiService = Get.find<ApiService>();
  final SocketService _socketService = Get.find<SocketService>();

  var isLoadingGames = true.obs;
  var isLoadingSession = false.obs;
  var isLoadingLeaderboard = false.obs;

  var activeGames = <WebViewGameModel>[].obs;
  var currentSession = Rxn<GameSessionModel>();
  var leaderboard = <GameLeaderboardEntry>[].obs;

  var selectedGame = Rxn<WebViewGameModel>();
  var currentBetAmount = 10.obs;
  var errorMessage = Rxn<String>();

  var selectedLeaderboardPeriod = 'weekly'.obs;
  var coins = 0.obs;
  var diamonds = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchActiveGames();
    _listenToSocketEvents();
  }

  @override
  void onClose() {
    _socketService.off('game_update');
    _socketService.off('game_completed');
    _socketService.off('game_ended');
    _socketService.off('error');
    super.onClose();
  }

  Future<void> fetchActiveGames() async {
    try {
      isLoadingGames.value = true;
      errorMessage.value = null;
      final games = await _repository.getActiveGames();
      activeGames.assignAll(games);
    } catch (e) {
      errorMessage.value = 'Failed to load games: $e';
    } finally {
      isLoadingGames.value = false;
    }
  }

  Future<void> selectGame(WebViewGameModel game) async {
    selectedGame.value = game;
    currentBetAmount.value = game.minBetAmount;
    await _repository.getGameById(game.id);
  }

  Future<void> startGameSession() async {
    if (selectedGame.value == null) {
      errorMessage.value = 'Please select a game first';
      return;
    }

    final betAmount = currentBetAmount.value;
    if (betAmount < selectedGame.value!.minBetAmount || betAmount > selectedGame.value!.maxBetAmount) {
      errorMessage.value = 'Bet amount must be between ${selectedGame.value!.minBetAmount} and ${selectedGame.value!.maxBetAmount}';
      return;
    }

    try {
      isLoadingSession.value = true;
      errorMessage.value = null;

      final session = await _repository.startGameSession(selectedGame.value!.id, betAmount);
      currentSession.value = session;
      coins.value = session.coins;
      diamonds.value = session.diamonds;

      _repository.joinGameRoom(selectedGame.value!.id);
    } catch (e) {
      errorMessage.value = 'Failed to start game: $e';
    } finally {
      isLoadingSession.value = false;
    }
  }

  Future<void> endGameSession(int winAmount) async {
    if (currentSession.value == null) {
      errorMessage.value = 'No active game session';
      return;
    }

    try {
      final response = await _repository.endGameSession(currentSession.value!.sessionId, winAmount);
      if (response['success'] == true) {
        coins.value = response['balance']['coins'] ?? coins.value;
        diamonds.value = response['balance']['diamonds'] ?? diamonds.value;
      }
      currentSession.value = null;
    } catch (e) {
      errorMessage.value = 'Failed to end game session: $e';
    }
  }

  Future<void> fetchLeaderboard({String? gameId}) async {
    try {
      isLoadingLeaderboard.value = true;
      errorMessage.value = null;

      final entries = await _repository.getLeaderboard(
        period: selectedLeaderboardPeriod.value,
        gameId: gameId,
        limit: 50,
      );
      leaderboard.assignAll(entries);
    } catch (e) {
      errorMessage.value = 'Failed to load leaderboard: $e';
    } finally {
      isLoadingLeaderboard.value = false;
    }
  }

  void changeLeaderboardPeriod(String period) {
    selectedLeaderboardPeriod.value = period;
    fetchLeaderboard();
  }

  void _listenToSocketEvents() {
    _socketService.on('game_update', (data) {
      final Map<String, dynamic> event = Map<String, dynamic>.from(data);
      Get.log('Game update received: $event');
    });

    _socketService.on('game_completed', (data) {
      final Map<String, dynamic> event = Map<String, dynamic>.from(data);
      Get.log('Game completed: $event');
      coins.value = event['balance']['coins'] ?? coins.value;
      diamonds.value = event['balance']['diamonds'] ?? diamonds.value;
      currentSession.value = null;
    });

    _socketService.on('game_ended', (data) {
      final Map<String, dynamic> event = Map<String, dynamic>.from(data);
      if (event['success'] == true) {
        coins.value = event['balance']['coins'] ?? coins.value;
        diamonds.value = event['balance']['diamonds'] ?? diamonds.value;
        currentSession.value = null;
      }
    });

    _socketService.on('error', (data) {
      final Map<String, dynamic> event = Map<String, dynamic>.from(data);
      errorMessage.value = event['message'] ?? 'Game error occurred';
    });
  }

  void updateBetAmount(double amount) {
    if (selectedGame.value != null) {
      final clamped = amount.clamp(selectedGame.value!.minBetAmount.toDouble(), selectedGame.value!.maxBetAmount.toDouble());
      currentBetAmount.value = clamped.toInt();
    }
  }

  void clearError() {
    errorMessage.value = null;
  }

  void resetGameState() {
    _socketService.emit('leave_game_room', selectedGame.value?.id ?? '');
    currentSession.value = null;
    selectedGame.value = null;
    currentBetAmount.value = 10;
    errorMessage.value = null;
  }
}