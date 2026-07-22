// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/gift/presentation/controllers/gift_controller.dart
// ARVIND PARTY - GIFT CONTROLLER (Extended: Lucky, Treasure, Combo, Collection, Goals)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/services/api_service.dart';
import '../../models/gift_model.dart';
import '../widgets/gift_picker_dialog.dart';

class GiftController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final isLoading = false.obs;
  final gifts = <GiftModel>[].obs;
  final giftHistory = <GiftHistoryModel>[].obs;
  final giftRanking = <Map<String, dynamic>>[].obs;
  final selectedCategory = Rxn<GiftCategory>();
  final selectedGift = Rxn<GiftModel>();

  // Categorized store gifts
  final hotGifts = <GiftModel>[].obs;
  final basicGifts = <GiftModel>[].obs;
  final premiumGifts = <GiftModel>[].obs;
  final luxuryGifts = <GiftModel>[].obs;
  final vipGifts = <GiftModel>[].obs;
  final luckyGifts = <GiftModel>[].obs;
  final festivalGifts = <GiftModel>[].obs;

  // Inventory & Collection
  final inventory = <GiftInventoryItem>[].obs;
  final collection = <GiftCollectionItem>[].obs;
  final uniqueCollectionCount = 0.obs;

  // Gift Goal
  final currentGiftGoal = Rxn<GiftGoalModel>();

  // Live gift event (for animation trigger)
  final Rx<GiftEventModel?> liveGiftEvent = Rxn<GiftEventModel?>();

  // Combo counter
  final comboCounter = 0.obs;
  final comboMultiplier = 1.obs;
  final isComboActive = false.obs;

  // Treasure state
  final isTreasureActive = false.obs;
  final treasurePoolCoins = 0.obs;
  final treasureDuration = 30.obs;

  // Lucky jackpot
  final Rx<GiftEventModel?> luckyJackpotEvent = Rxn<GiftEventModel?>();

  List<GiftModel> get filteredGifts {
    if (selectedCategory.value == null) return gifts;
    return gifts.where((g) => g.category == selectedCategory.value).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchGifts();
    fetchGiftInventory();
    fetchGiftCollection();
  }

  Future<void> fetchGifts() async {
    isLoading.value = true;
    try {
      final response = await _apiService.get('/gifts/store');
      if (response is Map && response['success'] == true) {
        final data = response['gifts'] as List? ?? [];
        gifts.assignAll(data.map((g) => GiftModel.fromJson(Map<String, dynamic>.from(g))).toList());

        // Categorized
        final cat = response['categorized'] as Map? ?? {};
        hotGifts.assignAll((cat['hot'] as List? ?? []).map((g) => GiftModel.fromJson(Map<String, dynamic>.from(g))).toList());
        basicGifts.assignAll((cat['basic'] as List? ?? []).map((g) => GiftModel.fromJson(Map<String, dynamic>.from(g))).toList());
        premiumGifts.assignAll((cat['premium'] as List? ?? []).map((g) => GiftModel.fromJson(Map<String, dynamic>.from(g))).toList());
        luxuryGifts.assignAll((cat['luxury'] as List? ?? []).map((g) => GiftModel.fromJson(Map<String, dynamic>.from(g))).toList());
        vipGifts.assignAll((cat['vip'] as List? ?? []).map((g) => GiftModel.fromJson(Map<String, dynamic>.from(g))).toList());
        luckyGifts.assignAll((cat['lucky'] as List? ?? []).map((g) => GiftModel.fromJson(Map<String, dynamic>.from(g))).toList());
        festivalGifts.assignAll((cat['festival'] as List? ?? []).map((g) => GiftModel.fromJson(Map<String, dynamic>.from(g))).toList());
      }
    } finally {
      isLoading.value = false;
    }
  }

  void filterByCategory(GiftCategory? category) {
    selectedCategory.value = category;
  }

  Future<bool> sendGift(String receiverId, GiftModel gift, {int quantity = 1, String? roomId, String? idempotencyKey}) async {
    try {
      final body = <String, dynamic>{
        'giftId': gift.id,
        'receiverId': receiverId,
        'quantity': quantity,
        if (roomId != null) 'roomId': roomId,
        if (idempotencyKey != null) 'idempotencyKey': idempotencyKey,
      };
      if (gift.comboEnabled) body['comboMultiplier'] = 1;

      final response = await _apiService.post('/gifts/send', body: body);
      if (response is Map && response['success'] == true) {
        // If lucky, show jackpot
        if (response['luckyMultiplier'] != null) {
          final multiplier = response['luckyMultiplier'] as int;
          final winAmount = response['luckyWinAmount'] as int? ?? 0;
          luckyJackpotEvent.value = GiftEventModel(
            eventId: '',
            giftId: gift.id,
            giftName: gift.giftName,
            senderId: '',
            senderName: 'You',
            receiverId: receiverId,
            receiverName: 'Receiver',
            coinCost: (gift.coinPrice * quantity).toInt(),
            isLucky: true,
            luckyMultiplier: multiplier,
            luckyWinAmount: winAmount,
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> sendComboGift(String receiverId, GiftModel gift, {int comboMultiplier = 5, String? roomId}) async {
    try {
      final response = await _apiService.post('/gifts/combo', body: {
        'giftId': gift.id,
        'receiverId': receiverId,
        'comboMultiplier': comboMultiplier,
        if (roomId != null) 'roomId': roomId,
      });
      return response is Map && response['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> claimTreasure(String giftEventId) async {
    try {
      final response = await _apiService.post('/gifts/treasure/claim', body: {
        'giftEventId': giftEventId,
      });
      if (response is Map && response['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> fetchGiftHistory() async {
    try {
      final response = await _apiService.get('/gifts/history');
      if (response is Map && response['success'] == true) {
        final data = response['history'] as List? ?? [];
        giftHistory.assignAll(data.map((g) => GiftHistoryModel.fromJson(Map<String, dynamic>.from(g))).toList());
      }
    } catch (e) {
      // Silently fail - non-critical data
    }
  }

  Future<void> fetchGiftRanking({String type = 'sender'}) async {
    try {
      final response = await _apiService.get('/gifts/leaderboard', query: {'type': type, 'limit': '50'});
      if (response is Map && response['success'] == true) {
        final data = response['leaderboard'] as List? ?? [];
        giftRanking.assignAll(data.map((g) => Map<String, dynamic>.from(g)).toList());
      }
    } catch (e) {
      // Silently fail - non-critical data
    }
  }

  Future<void> fetchGiftInventory() async {
    try {
      final response = await _apiService.get('/gifts/inventory');
      if (response is Map && response['success'] == true) {
        final data = response['inventory'] as List? ?? [];
        inventory.assignAll(data.map((i) => GiftInventoryItem.fromJson(Map<String, dynamic>.from(i))).toList());
      }
    } catch (e) {
      // Silently fail - non-critical data
    }
  }

  Future<void> fetchGiftCollection() async {
    try {
      final response = await _apiService.get('/gifts/collection');
      if (response is Map && response['success'] == true) {
        final data = response['collection'] as List? ?? [];
        collection.assignAll(data.map((c) => GiftCollectionItem.fromJson(Map<String, dynamic>.from(c))).toList());
        uniqueCollectionCount.value = response['uniqueGiftsCount'] ?? 0;
      }
    } catch (e) {
      // Silently fail - non-critical data
    }
  }

  Future<void> fetchGiftStatistics() async {
    // Returns map with totals
    try {
      await _apiService.get('/gifts/statistics');
    } catch (e) {
      // Silently fail - non-critical data
    }
  }

  Future<void> setGiftGoal(String roomId, int targetCoins, {String? title}) async {
    try {
      final response = await _apiService.post('/gifts/goals', body: {
        'roomId': roomId,
        'targetCoins': targetCoins,
        'title': title ?? 'Room Gift Goal',
      });
      if (response is Map && response['success'] == true) {
        final goal = GiftGoalModel.fromJson(Map<String, dynamic>.from(response['goal']));
        currentGiftGoal.value = goal;
      }
    } catch (e) {
      // Silently fail - non-critical data
    }
  }

  void updateGiftGoalProgress(int currentCoins, int targetCoins) {
    if (currentGiftGoal.value != null) {
      currentGiftGoal.value = GiftGoalModel(
        targetCoins: targetCoins,
        currentCoins: currentCoins,
        title: currentGiftGoal.value!.title,
        progressPercent: targetCoins > 0 ? (currentCoins / targetCoins).clamp(0.0, 1.0) : 0.0,
      );
    }
  }

  void onLiveGiftEffect(GiftEventModel event) {
    liveGiftEvent.value = event;

    // Auto-clear after animation duration
    Future.delayed(const Duration(seconds: 8), () {
      if (liveGiftEvent.value?.eventId == event.eventId) {
        liveGiftEvent.value = null;
      }
    });

    // Handle combo counter
    if (event.isComboGift) {
      isComboActive.value = true;
      comboMultiplier.value = event.comboMultiplier;
      comboCounter.value = event.quantity;
      Future.delayed(const Duration(seconds: 3), () {
        isComboActive.value = false;
        comboCounter.value = 0;
        comboMultiplier.value = 1;
      });
    }

    // Handle treasure activation
    if (event.isTreasure) {
      isTreasureActive.value = true;
      final treasureSecs = event.treasureDurationSeconds ?? 30;
      Future.delayed(Duration(seconds: treasureSecs), () {
        isTreasureActive.value = false;
      });
    }

    // Handle lucky jackpot
    if (event.isJackpot) {
      luckyJackpotEvent.value = event;
      Future.delayed(const Duration(seconds: 5), () {
        luckyJackpotEvent.value = null;
      });
    }
  }

  void onComboCounterUpdate(Map<String, dynamic> data) {
    isComboActive.value = true;
    comboMultiplier.value = data['comboMultiplier'] ?? 1;
    comboCounter.value = data['totalQuantity'] ?? 0;

    if (data['isFinal'] == true) {
      Future.delayed(const Duration(seconds: 2), () {
        isComboActive.value = false;
        comboCounter.value = 0;
      });
    }
  }

  void onTreasureSpawned(Map<String, dynamic> data) {
    isTreasureActive.value = true;
    treasurePoolCoins.value = data['poolCoins'] ?? 0;
    treasureDuration.value = data['durationSeconds'] ?? 30;
  }

  void openGiftPicker({String targetType = 'USER', String? targetId, String? roomId}) {
    Get.dialog(
      GiftPickerDialog(),
      barrierDismissible: true,
    );
  }

  void selectGift(GiftModel gift) {
    selectedGift.value = gift;
  }

  void clearSelection() {
    selectedGift.value = null;
  }

  @override
  void onClose() {
    clearSelection();
    super.onClose();
  }
}