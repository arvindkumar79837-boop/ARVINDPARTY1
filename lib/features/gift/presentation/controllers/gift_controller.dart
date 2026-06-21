// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/gift/presentation/controllers/gift_controller.dart
// ARVIND PARTY - GIFT CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/api_service.dart';
import '../../models/gift_model.dart';

class GiftController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final isLoading = false.obs;
  final gifts = <GiftModel>[].obs;
  final giftHistory = <GiftHistoryModel>[].obs;
  final giftRanking = <Map<String, dynamic>>[].obs;
  final selectedCategory = Rxn<GiftCategory>();
  final selectedGift = Rxn<GiftModel>();

  List<GiftModel> get filteredGifts {
    if (selectedCategory.value == null) return gifts;
    return gifts.where((g) => g.category == selectedCategory.value).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchGifts();
  }

  Future<void> fetchGifts() async {
    isLoading.value = true;
    try {
      final response = await _apiService.get('/gifts');
      if (response is Map && response['success'] == true) {
        final data = response['data'] as List? ?? [];
        gifts.assignAll(data.map((g) => GiftModel.fromJson(Map<String, dynamic>.from(g))).toList());
      }
    } catch (e) {
      debugPrint('[GiftController] fetchGifts error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterByCategory(GiftCategory? category) {
    selectedCategory.value = category;
  }

  Future<bool> sendGift(String receiverId, GiftModel gift, {int quantity = 1, String? roomId}) async {
    try {
      final response = await _apiService.post(
        '/gifts/send',
        body: {
          'giftId': gift.id,
          'receiverId': receiverId,
          'quantity': quantity,
          if (roomId != null) 'roomId': roomId,
        },
      );
      return response is Map && response['success'] == true;
    } catch (e) {
      debugPrint('[GiftController] sendGift error: $e');
      return false;
    }
  }

  Future<void> fetchGiftHistory() async {
    try {
      final response = await _apiService.get('/gifts/statistics');
      if (response is Map && response['success'] == true) {
        final data = response['data'] as List? ?? [];
        giftHistory.assignAll(data.map((g) => GiftHistoryModel.fromJson(Map<String, dynamic>.from(g))).toList());
      }
    } catch (e) {
      debugPrint('[GiftController] fetchGiftHistory error: $e');
    }
  }

  Future<void> fetchGiftRanking() async {
    try {
      final response = await _apiService.get('/gifts/leaderboard');
      if (response is Map && response['success'] == true) {
        final data = response['data'] as List? ?? [];
        giftRanking.assignAll(data.map((g) => Map<String, dynamic>.from(g)).toList());
      }
    } catch (e) {
      debugPrint('[GiftController] fetchGiftRanking error: $e');
    }
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
