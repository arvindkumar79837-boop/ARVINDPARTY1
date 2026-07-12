import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../repositories/events_repository.dart';

class EventsController extends GetxController {
  EventsController({EventsRepository? eventsRepository})
      : _repo = eventsRepository ?? EventsRepository();

  final isLoading = false.obs;
  final isCreating = false.obs;
  final events = <Map<String, dynamic>>[].obs;
  final selectedType = ''.obs;
  final selectedStatus = ''.obs;
  final errorMessage = Rxn<String>();
  final activeEvents = <Map<String, dynamic>>[].obs;
  final dailyTasks = <Map<String, dynamic>>[].obs;
  final tournaments = <Map<String, dynamic>>[].obs;
  final championships = <Map<String, dynamic>>[].obs;
  final treasureHunts = <Map<String, dynamic>>[].obs;

  // New observables
  final luckyDraws = <Map<String, dynamic>>[].obs;
  final selectedLuckyDraw = Rxn<Map<String, dynamic>>();
  final isSpinning = false.obs;
  final spinResult = Rxn<Map<String, dynamic>>();
  final inviteLink = Rxn<Map<String, dynamic>>();
  final inviteStats = Rxn<Map<String, dynamic>>();
  final loginStreak = Rxn<Map<String, dynamic>>();
  final isClaimingLogin = false.obs;

  final EventsRepository _repo;

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    await Future.wait([
      fetchEvents(),
      fetchActiveEvents(),
      fetchTournaments(),
      fetchChampionships(),
      fetchTreasureHunts(),
      fetchLuckyDraws(),
      fetchDailyTasks(),
    ]);
  }

  Future<void> fetchEvents() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      final result = await _repo.fetchEvents(
        type: selectedType.value.isEmpty ? null : selectedType.value,
        status: selectedStatus.value.isEmpty ? null : selectedStatus.value,
      );
      events.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchActiveEvents() async {
    try {
      final result = await _repo.fetchActiveEvents();
      activeEvents.assignAll(result);
    } catch (e) {
      debugPrint('[EventsController] fetchActiveEvents error: $e');
    }
  }

  Future<void> fetchTournaments() async {
    try {
      final result = await _repo.fetchTournaments();
      tournaments.assignAll(result);
    } catch (e) {
      debugPrint('[EventsController] fetchTournaments error: $e');
    }
  }

  Future<void> fetchChampionships() async {
    try {
      final result = await _repo.fetchChampionships();
      championships.assignAll(result);
    } catch (e) {
      debugPrint('[EventsController] fetchChampionships error: $e');
    }
  }

  Future<void> fetchTreasureHunts() async {
    try {
      final result = await _repo.fetchTreasureHunts();
      treasureHunts.assignAll(result);
    } catch (e) {
      debugPrint('[EventsController] fetchTreasureHunts error: $e');
    }
  }

  // ─── NEW: LUCKY DRAW METHODS ─────────────────────────────────────────
  Future<void> fetchLuckyDraws() async {
    try {
      final result = await _repo.fetchActiveLuckyDraws();
      luckyDraws.assignAll(result);
    } catch (e) {
      debugPrint('[EventsController] fetchLuckyDraws error: $e');
    }
  }

  Future<void> selectLuckyDraw(String drawId) async {
    try {
      final result = await _repo.getLuckyDrawById(drawId);
      selectedLuckyDraw.value = result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load lucky draw');
    }
  }

  Future<void> spinWheel(String drawId) async {
    if (isSpinning.value) return;
    try {
      isSpinning.value = true;
      spinResult.value = null;
      final result = await _repo.spinWheel(drawId);
      spinResult.value = result;
      if (result['jackpot_hit'] == true) {
        Get.snackbar(
          'JACKPOT!',
          'You hit the jackpot!',
          backgroundColor: Colors.amber,
        );
      } else {
        final prize = result['prize'] as Map<String, dynamic>?;
        if (prize != null) {
          Get.snackbar(
            'You Won!',
            '${prize['label']}: ${prize['prize_value']} ${prize['prize_type']}',
            backgroundColor: const Color(0xFFD4AF37),
          );
        }
      }
      await fetchLuckyDraws();
      if (selectedLuckyDraw.value != null) {
        await selectLuckyDraw(drawId);
      }
    } catch (e) {
      Get.snackbar('Spin Failed', e.toString());
    } finally {
      isSpinning.value = false;
    }
  }

  // ─── NEW: DAILY TASKS METHODS ────────────────────────────────────────
  Future<void> fetchDailyTasks() async {
    try {
      final result = await _repo.fetchActiveDailyTasks();
      dailyTasks.assignAll(result);
    } catch (e) {
      // silently fail
    }
  }

  Future<void> updateTaskProgress(String taskId, {int increment = 1}) async {
    try {
      await _repo.updateTaskProgress(taskId, increment);
      await fetchDailyTasks();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update progress');
    }
  }

  Future<void> claimTaskReward(String taskId) async {
    try {
      final result = await _repo.claimTaskReward(taskId);
      Get.snackbar(
        'Reward Claimed!',
        '+${result['coins'] ?? 0} Coins, +${result['xp'] ?? 0} XP',
        backgroundColor: Colors.green,
      );
      await fetchDailyTasks();
    } catch (e) {
      Get.snackbar('Error', 'Failed to claim reward: ${e.toString()}');
    }
  }

  // ─── NEW: INVITE METHODS ─────────────────────────────────────────────
  Future<void> generateInviteLink({int commissionPercent = 5}) async {
    try {
      final result = await _repo.generateInviteLink(commissionPercent);
      inviteLink.value = result;
      await getInviteStats();
      Get.snackbar('Invite Link', 'Link generated successfully!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate invite link');
    }
  }

  Future<void> getInviteStats() async {
    try {
      final result = await _repo.getInviteStats();
      inviteStats.value = result;
    } catch (e) {
      // silently fail
    }
  }

  // ─── NEW: LOGIN STREAK METHODS ───────────────────────────────────────
  Future<void> fetchLoginStreak() async {
    try {
      final result = await _repo.getLoginStreak();
      loginStreak.value = result;
    } catch (e) {
      // silently fail
    }
  }

  Future<void> claimDailyLoginReward() async {
    if (isClaimingLogin.value) return;
    try {
      isClaimingLogin.value = true;
      final result = await _repo.claimDailyLogin();
      if (result['already_claimed_today'] == true) {
        Get.snackbar('Already Claimed', 'Login reward already claimed today');
      } else {
        final reward = result['reward'] as Map<String, dynamic>? ?? {};
        final special = result['special_reward'];
        var msg = '+${reward['coins'] ?? 0} Coins, +${reward['xp'] ?? 0} XP';
        if (special != null) {
          msg += '\n🎁 ${special['name'] ?? 'Special Reward'} unlocked!';
        }
        Get.snackbar(
          'Login Streak Day ${result['streak'] ?? 1}',
          msg,
          backgroundColor: Colors.blueGrey,
        );
      }
      loginStreak.value = result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to claim login reward');
    } finally {
      isClaimingLogin.value = false;
    }
  }

  Future<void> registerForTournament(String tournamentId) async {
    try {
      await _repo.registerForTournament(tournamentId);
      Get.snackbar('Success', 'Registered for tournament');
      await fetchTournaments();
    } catch (e) {
      Get.snackbar('Error', 'Failed to register: ${e.toString()}');
    }
  }

  Future<void> qualifyForChampionship(String championshipId) async {
    try {
      await _repo.qualifyForChampionship(championshipId);
      Get.snackbar('Success', 'Qualified for championship');
      await fetchChampionships();
    } catch (e) {
      Get.snackbar('Error', 'Failed to qualify: ${e.toString()}');
    }
  }

  Future<void> collectTreasureKey(String huntId) async {
    try {
      final result = await _repo.collectTreasureKey(huntId);
      if (result['isFound'] == true) {
        Get.snackbar('Treasure Found!', 'Rewards have been distributed!', backgroundColor: const Color(0xFFD4AF37));
      } else {
        Get.snackbar('Key Collected', '${result['keysCollected']}/${result['keysRequired']} keys');
      }
      await fetchTreasureHunts();
    } catch (e) {
      Get.snackbar('Error', 'Failed to collect key: ${e.toString()}');
    }
  }

  Future<void> createEvent({
    required String title,
    required String description,
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    String? coverImage,
    int maxParticipants = 0,
  }) async {
    if (title.trim().isEmpty || description.trim().isEmpty) {
      Get.snackbar('Error', 'Title and description are required');
      return;
    }

    if (endDate.isBefore(startDate)) {
      Get.snackbar('Error', 'End date must be after start date');
      return;
    }

    try {
      isCreating.value = true;
      final eventData = {
        'title': title.trim(),
        'description': description.trim(),
        'type': type,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        if (coverImage != null && coverImage.trim().isNotEmpty) 'coverImage': coverImage.trim(),
        'maxParticipants': maxParticipants,
      };
      final createdEvent = await _repo.createEvent(eventData);

      events.insert(0, createdEvent);
      Get.back();
      Get.snackbar('Success', 'Event created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create event: ${e.toString()}');
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> applyFilters({
    String? type,
    String? status,
  }) async {
    selectedType.value = type ?? '';
    selectedStatus.value = status ?? '';
    await fetchEvents();
  }

  // ═════════════════════════════════════════════════════════════════════
  // NEW: MASTER EVENT ENGINE METHODS
  // ═════════════════════════════════════════════════════════════════════
  Future<void> fetchMasterActiveEvents() async {
    try {
      final result = await _repo.fetchMasterActiveEvents();
      activeEvents.assignAll(result);
    } catch (e) {
      debugPrint('[EventsController] fetchMasterActiveEvents error: $e');
    }
  }

  Future<void> joinEvent(String eventId) async {
    try {
      final result = await _repo.joinEvent(eventId);
      Get.snackbar('Success', 'Joined event successfully!', backgroundColor: Colors.green);
      await fetchMasterActiveEvents();
      await fetchEventsDashboard();
    } catch (e) {
      Get.snackbar('Error', 'Failed to join event: ${e.toString()}');
    }
  }

  Future<void> leaveEvent(String eventId) async {
    try {
      final result = await _repo.leaveEvent(eventId);
      Get.snackbar('Left Event', 'You have left the event');
      await fetchMasterActiveEvents();
    } catch (e) {
      Get.snackbar('Error', 'Failed to leave event: ${e.toString()}');
    }
  }

  Future<void> claimEventReward(String eventId) async {
    try {
      final result = await _repo.claimEventReward(eventId);
      final rewards = result['rewards'] as Map<String, dynamic>? ?? {};
      var msg = '';
      if ((rewards['coins'] ?? 0) > 0) msg += '+${rewards['coins']} Coins\n';
      if ((rewards['diamonds'] ?? 0) > 0) msg += '+${rewards['diamonds']} Diamonds\n';
      if ((rewards['xp'] ?? 0) > 0) msg += '+${rewards['xp']} XP';
      Get.snackbar('Reward Claimed!', msg.trim(), backgroundColor: Colors.green);
      await fetchMasterActiveEvents();
    } catch (e) {
      Get.snackbar('Error', 'Failed to claim reward: ${e.toString()}');
    }
  }

  Future<void> fetchEventsDashboard() async {
    try {
      final dashboard = await _repo.getEventsDashboard();
      final pending = dashboard['pending_events'] as List<dynamic>? ?? [];
      final completed = dashboard['completed_events'] as List<dynamic>? ?? [];
      Get.put<EventsController>(this, permanent: true);
      // Controller will expose these via observables in next iteration
    } catch (e) {
      debugPrint('[EventsController] fetchEventsDashboard error: $e');
    }
  }

  Future<void> fetchWelcomeWeekTasks() async {
    try {
      final tasks = await _repo.getWelcomeWeekTasks();
      // Will be exposed via observable in next iteration
    } catch (e) {
      debugPrint('[EventsController] fetchWelcomeWeekTasks error: $e');
    }
  }

  Future<void> fetchFestivalGifts({String? festivalType}) async {
    try {
      final gifts = await _repo.getFestivalGifts(festivalType);
      // Will be exposed via observable in next iteration
    } catch (e) {
      debugPrint('[EventsController] fetchFestivalGifts error: $e');
    }
  }

  Future<void> fetchAnniversaryRewards({int? year}) async {
    try {
      final rewards = await _repo.getAnniversaryRewards(year);
      // Will be exposed via observable in next iteration
    } catch (e) {
      debugPrint('[EventsController] fetchAnniversaryRewards error: $e');
    }
  }
}
