import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/socket/socket_service.dart';
import '../repositories/family_repository.dart';

class FamilyController extends GetxController {
  final FamilyRepository _repo = FamilyRepository();
  final SocketService _socket = Get.find<SocketService>();

  final isLoading = false.obs;
  final isCreating = false.obs;
  final isJoining = false.obs;
  final isLeaving = false.obs;
  final isClaiming = false.obs;
  final isSendingMessage = false.obs;
  final isContributing = false.obs;
  final isWithdrawing = false.obs;

  final myFamily = Rxn<Map<String, dynamic>>();
  final familyTasks = <Map<String, dynamic>>[].obs;
  final familyRanking = <Map<String, dynamic>>[].obs;
  final familyDetails = Rxn<Map<String, dynamic>>();
  final allFamilies = <Map<String, dynamic>>[].obs;
  final chatMessages = <Map<String, dynamic>>[].obs;
  final familyInventory = <Map<String, dynamic>>[].obs;
  final shopItems = <Map<String, dynamic>>[].obs;
  final activePK = Rxn<Map<String, dynamic>>();
  final pkHistory = <Map<String, dynamic>>[].obs;
  final activeWars = <Map<String, dynamic>>[].obs;
  final warHistory = <Map<String, dynamic>>[].obs;

  // ─── INVITATION SYSTEM ───────────────────────────────────────────────
  final myInvitations = <Map<String, dynamic>>[].obs;
  final sentInvitations = <Map<String, dynamic>>[].obs;
  final searchResults = <Map<String, dynamic>>[].obs;

  // ─── ADMIN MANAGEMENT ────────────────────────────────────────────────
  final adminList = <Map<String, dynamic>>[].obs;
  final maxAdminSlots = 5.obs;
  final currentAdminCount = 0.obs;

  // ─── LEADERBOARD ─────────────────────────────────────────────────────
  final leaderboardEntries = <Map<String, dynamic>>[].obs;
  final topContributors = <Map<String, dynamic>>[].obs;
  final selectedPeriod = 'all_time'.obs;

  // ─── STAY REWARD ─────────────────────────────────────────────────────
  final staySession = Rxn<Map<String, dynamic>>();
  final stayHistory = <Map<String, dynamic>>[].obs;
  final isStayActive = false.obs;
  final stayCooldownMs = 0.obs;
  final stayCanRedeem = false.obs;

  // ─── REWARD CONFIG ───────────────────────────────────────────────────
  final rewardConfig = Rxn<Map<String, dynamic>>();

  final createFormKey = GlobalKey<FormState>();
  final familyNameController = TextEditingController();
  final familyBadgeController = TextEditingController();
  final familySloganController = TextEditingController();
  final familyIntroController = TextEditingController();
  final joinFamilyIdController = TextEditingController();
  final messageController = TextEditingController();
  final searchQueryController = TextEditingController();
  final inviteMessageController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchMyFamily();
    _setupSocketListeners();
  }

  @override
  void onClose() {
    familyNameController.dispose();
    familyBadgeController.dispose();
    familySloganController.dispose();
    familyIntroController.dispose();
    joinFamilyIdController.dispose();
    messageController.dispose();
    searchQueryController.dispose();
    inviteMessageController.dispose();
    super.onClose();
  }

  void _setupSocketListeners() {
    _socket.on('family:new_message', (data) {
      chatMessages.insert(0, Map<String, dynamic>.from(data));
    });

    _socket.on('family:invitation_received', (data) {
      myInvitations.insert(0, Map<String, dynamic>.from(data));
      Get.snackbar('Family Invitation!', data['message'] ?? 'You received a family invitation');
    });

    _socket.on('family:member_joined', (data) {
      Get.snackbar('New Member!', '${data['username'] ?? 'Someone'} joined the family');
    });

    _socket.on('family:level_up', (data) {
      final newLevel = data['newLevel'] ?? 0;
      Get.snackbar('🎉 Family Level Up!', 'Your family is now Level $newLevel!');
    });

    _socket.on('family:stay:reward', (data) {
      final coins = data['coinsEarned'] ?? 0;
      final xp = data['xpEarned'] ?? 0;
      Get.snackbar('Stay Reward!', '+$coins coins & +$xp XP');
    });

    _socket.on('family:stay:status', (data) {
      final active = data['active'] ?? false;
      isStayActive.value = active;
      if (active) {
        stayCanRedeem.value = data['canRedeem'] ?? false;
        stayCooldownMs.value = data['remainingMs'] ?? 0;
      }
    });

    _socket.on('family:pk_update', (data) {
      final pk = Map<String, dynamic>.from(data);
      if (activePK.value != null) {
        activePK.value = pk;
      }
    });

    _socket.on('family:pk_ended', (data) {
      final pk = Map<String, dynamic>.from(data);
      if (activePK.value != null) {
        activePK.value = pk;
      }
    });

    _socket.on('family:war_update', (data) {
      final war = Map<String, dynamic>.from(data);
      final index = activeWars.indexWhere((w) => w['_id'] == war['_id']);
      if (index != -1) {
        activeWars[index] = war;
        activeWars.refresh();
      }
    });
  }

  Future<void> fetchMyFamily() async {
    try {
      isLoading.value = true;
      final data = await _repo.getMyFamily();
      myFamily.value = data;
      if (data['family_id'] != null) {
        maxAdminSlots.value = data['maxAdminSlots'] ?? 5;
        topContributors.assignAll(List<Map<String, dynamic>>.from(data['topContributors'] ?? []));
        fetchFamilyTasks();
        fetchFamilyInventory();
        fetchShopItems();
        fetchAdminList();
        fetchActivePK();
        fetchPKHistory();
        fetchActiveWars();
        fetchMyStaySession();
        fetchRewardConfig();
      }
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
      myFamily.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  bool validateCreateForm() {
    return createFormKey.currentState?.validate() ?? false;
  }

  Future<void> createFamily() async {
    if (!validateCreateForm()) return;

    try {
      isCreating.value = true;
      final data = await _repo.createFamily(
        familyName: familyNameController.text.trim(),
        familyBadge: familyBadgeController.text.trim().toUpperCase(),
        slogan: familySloganController.text.trim(),
        familyIntro: familyIntroController.text.trim(),
      );

      myFamily.value = data;
      Get.snackbar('Success', 'Family created successfully!');
      _clearCreateForm();
      Get.back();
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
    } finally {
      isCreating.value = false;
    }
  }

  void _clearCreateForm() {
    familyNameController.clear();
    familyBadgeController.clear();
    familySloganController.clear();
    familyIntroController.clear();
  }

  Future<void> joinFamily() async {
    final familyId = joinFamilyIdController.text.trim();
    if (familyId.isEmpty) {
      Get.snackbar('Validation', 'Please enter a Family ID');
      return;
    }

    try {
      isJoining.value = true;
      final data = await _repo.joinFamily(familyId);
      myFamily.value = data;
      Get.snackbar('Success', 'Joined family successfully!');
      _clearJoinForm();
      Get.back();
      fetchMyFamily();
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
    } finally {
      isJoining.value = false;
    }
  }

  void _clearJoinForm() {
    joinFamilyIdController.clear();
  }

  Future<void> leaveFamily() async {
    try {
      isLeaving.value = true;
      await _repo.leaveFamily();
      myFamily.value = null;
      chatMessages.clear();
      Get.snackbar('Success', 'Left family successfully.');
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
    } finally {
      isLeaving.value = false;
    }
  }

  Future<void> updateFamilyProfile() async {
    try {
      isCreating.value = true;
      await _repo.updateFamilyDetails(
        familyName: familyNameController.text.trim().isNotEmpty ? familyNameController.text.trim() : null,
        familyBadge: familyBadgeController.text.trim().isNotEmpty ? familyBadgeController.text.trim().toUpperCase() : null,
        familySlogan: familySloganController.text.trim().isNotEmpty ? familySloganController.text.trim() : null,
        familyIntro: familyIntroController.text.trim().isNotEmpty ? familyIntroController.text.trim() : null,
      );
      Get.snackbar('Success', 'Family profile updated!');
      fetchMyFamily();
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
    } finally {
      isCreating.value = false;
    }
  }

  // ─── INVITATION SYSTEM ───────────────────────────────────────────────

  Future<void> searchUsersToInvite(String query) async {
    try {
      isLoading.value = true;
      final users = await _repo.searchUsersToInvite(query);
      searchResults.assignAll(users);
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendInvitation(String receiverUid) async {
    try {
      isCreating.value = true;
      await _repo.sendInvitation(
        receiverUid: receiverUid,
        message: inviteMessageController.text.trim().isNotEmpty
            ? inviteMessageController.text.trim()
            : null,
      );
      Get.snackbar('Success', 'Invitation sent!');
      inviteMessageController.clear();
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> fetchMyInvitations({String status = 'pending'}) async {
    try {
      isLoading.value = true;
      final invitations = await _repo.getMyInvitations(status: status);
      myInvitations.assignAll(invitations);
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSentInvitations() async {
    try {
      isLoading.value = true;
      final invitations = await _repo.getSentInvitations();
      sentInvitations.assignAll(invitations);
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> respondToInvitation(String invitationId, String action) async {
    try {
      isJoining.value = true;
      await _repo.respondToInvitation(
        invitationId: invitationId,
        action: action,
      );
      myInvitations.removeWhere((inv) => inv['invitation_id'] == invitationId);
      if (action == 'accepted') {
        Get.snackbar('Success', 'You joined the family!');
        fetchMyFamily();
      } else {
        Get.snackbar('Success', 'Invitation rejected.');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
    } finally {
      isJoining.value = false;
    }
  }

  Future<void> cancelInvitation(String invitationId) async {
    try {
      await _repo.cancelInvitation(invitationId);
      sentInvitations.removeWhere((inv) => inv['invitation_id'] == invitationId);
      Get.snackbar('Success', 'Invitation cancelled.');
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
    }
  }

  // ─── ADMIN MANAGEMENT ────────────────────────────────────────────────

  Future<void> fetchAdminList() async {
    try {
      final data = await _repo.getAdminList();
      adminList.assignAll(List<Map<String, dynamic>>.from(data['admins_list'] ?? []));
      currentAdminCount.value = data['currentAdminCount'] ?? 0;
      maxAdminSlots.value = data['maxAdminSlots'] ?? 5;
    } catch (e) {
    }
  }

  Future<void> assignAdmin(String targetUid, {String? adminRole}) async {
    try {
      isCreating.value = true;
      await _repo.assignAdmin(targetUid: targetUid, adminRole: adminRole);
      Get.snackbar('Success', 'Admin assigned!');
      fetchAdminList();
      fetchMyFamily();
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> removeAdmin(String targetUid) async {
    try {
      isCreating.value = true;
      await _repo.removeAdmin(targetUid);
      Get.snackbar('Success', 'Admin removed.');
      fetchAdminList();
      fetchMyFamily();
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> transferOwnership(String targetUid) async {
    try {
      isCreating.value = true;
      await _repo.transferOwnership(targetUid);
      Get.snackbar('Success', 'Ownership transferred!');
      fetchMyFamily();
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
    } finally {
      isCreating.value = false;
    }
  }

  // ─── FAMILY TASKS ────────────────────────────────────────────────────

  Future<void> fetchFamilyTasks() async {
    try {
      isLoading.value = true;
      final tasks = await _repo.getFamilyTasks();
      familyTasks.assignAll(tasks);
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> claimTaskReward(String taskId) async {
    try {
      isClaiming.value = true;
      final result = await _repo.updateTaskProgress(taskId, 1);
      Get.snackbar('Reward Claimed', 'Task completed! Family: +${result['totalXp'] ?? 0} XP');
      if (myFamily.value != null) {
        myFamily.value!['total_xp'] = result['totalXp'] ?? myFamily.value!['total_xp'];
        myFamily.value!['family_points'] = result['familyPoints'] ?? myFamily.value!['family_points'];
        myFamily.value!['current_level'] = result['currentLevel'] ?? myFamily.value!['current_level'];
        myFamily.refresh();
      }
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
    } finally {
      isClaiming.value = false;
    }
  }

  // ─── LEADERBOARD ─────────────────────────────────────────────────────

  Future<void> fetchFamilyLeaderboard({String period = 'all_time'}) async {
    try {
      isLoading.value = true;
      selectedPeriod.value = period;
      final data = await _repo.getFamilyLeaderboard(period: period);
      leaderboardEntries.assignAll(List<Map<String, dynamic>>.from(data['leaderboard'] ?? []));
      topContributors.assignAll(List<Map<String, dynamic>>.from(data['top3'] ?? []));
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  void changeLeaderboardPeriod(String period) {
    selectedPeriod.value = period;
    fetchFamilyLeaderboard(period: period);
  }

  Future<void> updateLeaderboard() async {
    try {
      isLoading.value = true;
      await _repo.updateLeaderboard();
      Get.snackbar('Success', 'Leaderboard updated!');
      await fetchFamilyLeaderboard(period: selectedPeriod.value);
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  // ─── FAMILY RANKING ──────────────────────────────────────────────────

  Future<void> fetchFamilyRanking() async {
    try {
      isLoading.value = true;
      final ranking = await _repo.getFamilyRankings(type: selectedPeriod.value);
      familyRanking.assignAll(ranking['data'] ?? []);
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  void changePeriod(String period) {
    selectedPeriod.value = period;
    fetchFamilyRanking();
  }

  Future<void> fetchFamilyDetails(String familyId) async {
    try {
      isLoading.value = true;
      final data = await _repo.getFamilyById(familyId);
      familyDetails.value = data;
      topContributors.assignAll(List<Map<String, dynamic>>.from(data['topContributors'] ?? []));
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  // ─── STAY REWARD ─────────────────────────────────────────────────────

  Future<void> startStaySession({String? roomId, int seatIndex = 0}) async {
    try {
      final result = await _repo.startStaySession(roomId: roomId, seatIndex: seatIndex);
      isStayActive.value = true;
      Get.snackbar('Stay Started', 'You are now earning rewards for staying in the room!');
      fetchMyStaySession();
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
    }
  }

  Future<void> redeemStayReward() async {
    try {
      final result = await _repo.redeemStayReward();
      final data = result['data'] as Map<String, dynamic>? ?? result;
      Get.snackbar(
        'Reward Earned!',
        '+${data['coinsEarned'] ?? 0} coins & +${data['xpEarned'] ?? 0} XP',
      );
      fetchMyStaySession();
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
    }
  }

  Future<void> endStaySession() async {
    try {
      await _repo.endStaySession();
      isStayActive.value = false;
      staySession.value = null;
      Get.snackbar('Session Ended', 'Stay session ended.');
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
    }
  }

  Future<void> fetchMyStaySession() async {
    try {
      final data = await _repo.getMyStaySession();
      staySession.value = data['activeSession'] as Map<String, dynamic>?;
      isStayActive.value = staySession.value != null;
      stayHistory.assignAll(List<Map<String, dynamic>>.from(data['history'] ?? []));
    } catch (e) {
    }
  }

  // ─── REWARD CONFIG ───────────────────────────────────────────────────

  Future<void> fetchRewardConfig() async {
    try {
      final config = await _repo.getRewardConfig();
      rewardConfig.value = config;
    } catch (e) {
    }
  }

  Future<void> updateRewardConfig(Map<String, dynamic> config) async {
    try {
      isCreating.value = true;
      await _repo.updateRewardConfig(
        top1Reward: config['top1_reward'] as String?,
        top2Reward: config['top2_reward'] as String?,
        top3Reward: config['top3_reward'] as String?,
        stayRewardCoinsPer5min: config['stay_reward_coins_per_5min'] as int?,
        stayRewardXpPer5min: config['stay_reward_xp_per_5min'] as int?,
        customRewardsEnabled: config['custom_rewards_enabled'] as bool?,
      );
      Get.snackbar('Success', 'Reward configuration updated!');
      fetchRewardConfig();
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
    } finally {
      isCreating.value = false;
    }
  }

  // ─── SET OFFICIAL ROOM ──────────────────────────────────────────────

  Future<void> setOfficialRoom(String roomId) async {
    try {
      isCreating.value = true;
      await _repo.setOfficialRoom(roomId);
      Get.snackbar('Success', 'Official room set!');
      fetchMyFamily();
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
    } finally {
      isCreating.value = false;
    }
  }

  // ─── CHAT ────────────────────────────────────────────────────────────

  Future<void> fetchChatMessages({int page = 1, int limit = 50}) async {
    try {
      isLoading.value = true;
      final familyId = myFamily.value?['family_id'] ?? '';
      if (familyId.isEmpty) return;
      final messages = await _repo.getChatMessages(familyId, page: page, limit: limit);
      chatMessages.assignAll(messages);
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    try {
      isSendingMessage.value = true;
      final familyId = myFamily.value?['family_id'] ?? '';
      final message = await _repo.sendChatMessage(
        familyId: familyId,
        content: content.trim(),
      );
      chatMessages.insert(0, message);
      messageController.clear();
      _socket.emit('family:send_message', {
        'familyId': familyId,
        'message': content.trim(),
        'type': 'text',
      });
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
    } finally {
      isSendingMessage.value = false;
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      final familyId = myFamily.value?['family_id'] ?? '';
      await _repo.deleteChatMessage(familyId, messageId);
      chatMessages.removeWhere((msg) => msg['_id'] == messageId);
      Get.snackbar('Success', 'Message deleted');
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
    }
  }

  Future<void> pinMessage(String messageId) async {
    try {
      final familyId = myFamily.value?['_id'] ?? '';
      final result = await _repo.pinMessage(familyId, messageId);
      final index = chatMessages.indexWhere((msg) => msg['_id'] == messageId);
      if (index != -1) {
        chatMessages[index] = result['message'] as Map<String, dynamic>? ?? chatMessages[index];
        chatMessages.refresh();
      }
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
    }
  }

  // ─── SHOP ────────────────────────────────────────────────────────────

  Future<void> fetchShopItems() async {
    try {
      final items = await _repo.getShopItems();
      shopItems.assignAll(items);
    } catch (e) {
    }
  }

  Future<void> purchaseShopItem(String itemId) async {
    try {
      await _repo.purchaseShopItem(itemId);
      Get.snackbar('Success', 'Item purchased!');
      await fetchShopItems();
      await fetchFamilyInventory();
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
    }
  }

  Future<void> fetchFamilyInventory() async {
    try {
      final inventory = await _repo.getShopItems(category: 'inventory');
      familyInventory.assignAll(inventory);
    } catch (e) {
    }
  }

  // ─── PK BATTLES ──────────────────────────────────────────────────────

  Future<void> fetchActivePK() async {
    try {
      final pk = await _repo.getPKBattle('current');
      activePK.value = pk;
    } catch (e) {
    }
  }

  Future<void> fetchPKHistory() async {
    try {
      final history = await _repo.getPKBattle('history');
      pkHistory.assignAll(history['data'] as List<Map<String, dynamic>>? ?? []);
    } catch (e) {
    }
  }

  // ─── WARS ────────────────────────────────────────────────────────────

  Future<void> fetchActiveWars() async {
    try {
      final wars = await _repo.getFamilyWars();
      activeWars.assignAll(wars);
    } catch (e) {
    }
  }

  Future<void> fetchWarHistory() async {
    try {
      final history = await _repo.getMyActiveWars();
      warHistory.assignAll(history);
    } catch (e) {
    }
  }

  Future<void> registerForWar(String warId) async {
    try {
      final result = await _repo.startFamilyWar(warId);
      Get.snackbar('Success', 'Registered for war!');
      await fetchActiveWars();
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
    }
  }

  // ─── TREASURY OPERATIONS ────────────────────────────────────────────

  Future<bool> contributeToTreasury(double amount, {String? note}) async {
    try {
      isContributing.value = true;
      await _repo.contributeToTreasury(amount, note: note);
      fetchMyFamily();
      return true;
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
      return false;
    } finally {
      isContributing.value = false;
    }
  }

  Future<bool> withdrawFromTreasury(double amount, {String? reason}) async {
    try {
      isWithdrawing.value = true;
      await _repo.withdrawFromTreasury(amount, reason: reason);
      fetchMyFamily();
      return true;
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
      return false;
    } finally {
      isWithdrawing.value = false;
    }
  }

  // ─── SEARCH ──────────────────────────────────────────────────────────

  Future<void> searchFamilies(String query) async {
    try {
      isLoading.value = true;
      final result = await _repo.searchFamilies(query);
      allFamilies.assignAll(List<Map<String, dynamic>>.from(result['data'] ?? []));
    } catch (e) {
      Get.snackbar('Error', e.toString().replaceAll('ApiException: ', ''));
    } finally {
      isLoading.value = false;
    }
  }
}