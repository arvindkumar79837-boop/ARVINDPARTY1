// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/gift/presentation/repositories/gift_repository.dart
// ARVIND PARTY - GIFT REPOSITORY
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../models/gift_model.dart';

class GiftRepository extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  Future<List<Map<String, dynamic>>> fetchGifts() async {
    try {
      final response = await _api.get(ApiConstants.gifts);
      if (response is Map && response['data'] is List) {
        return List<Map<String, dynamic>>.from(response['data']);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<GiftModel>> fetchGiftCatalog() async {
    try {
      final response = await _api.get('${ApiConstants.gifts}/catalog');
      if (response is Map && response['data'] is List) {
        return (response['data'] as List)
            .map((g) => GiftModel.fromJson(Map<String, dynamic>.from(g)))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<GiftModel>> fetchGiftsByCategory(String category) async {
    try {
      final response = await _api.get('${ApiConstants.gifts}/category/$category');
      if (response is Map && response['data'] is List) {
        return (response['data'] as List)
            .map((g) => GiftModel.fromJson(Map<String, dynamic>.from(g)))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> sendGift(String giftId, String roomId, String recipientId, {int quantity = 1}) async {
    try {
      final response = await _api.post('${ApiConstants.gifts}/send', body: {
        'giftId': giftId,
        'roomId': roomId,
        'recipientId': recipientId,
        'quantity': quantity,
      });
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendComboGift(String giftId, String roomId, String recipientId, int comboCount) async {
    try {
      final response = await _api.post('${ApiConstants.gifts}/send-combo', body: {
        'giftId': giftId,
        'roomId': roomId,
        'recipientId': recipientId,
        'comboCount': comboCount,
      });
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<GiftHistoryModel>> fetchGiftHistory({int page = 1, int limit = 20}) async {
    try {
      final response = await _api.get('${ApiConstants.gifts}/history', query: {
        'page': page,
        'limit': limit,
      });
      if (response is Map && response['data'] is List) {
        return (response['data'] as List)
            .map((h) => GiftHistoryModel.fromJson(Map<String, dynamic>.from(h)))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<GiftInventoryItem>> fetchGiftInventory() async {
    try {
      final response = await _api.get('${ApiConstants.gifts}/inventory');
      if (response is Map && response['data'] is List) {
        return (response['data'] as List)
            .map((i) => GiftInventoryItem.fromJson(Map<String, dynamic>.from(i)))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<GiftCollectionItem>> fetchGiftCollection() async {
    try {
      final response = await _api.get('${ApiConstants.gifts}/collection');
      if (response is Map && response['data'] is List) {
        return (response['data'] as List)
            .map((c) => GiftCollectionItem.fromJson(Map<String, dynamic>.from(c)))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<GiftGoalModel?> fetchGiftGoal() async {
    try {
      final response = await _api.get('${ApiConstants.gifts}/goal');
      if (response is Map && response['success'] == true && response['data'] != null) {
        return GiftGoalModel.fromJson(Map<String, dynamic>.from(response['data']));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<GiftEventModel>> fetchGiftEvents({String? roomId, int limit = 20}) async {
    try {
      final queryParams = <String, dynamic>{'limit': limit};
      if (roomId != null) queryParams['roomId'] = roomId;
      final response = await _api.get('${ApiConstants.gifts}/events', query: queryParams);
      if (response is Map && response['data'] is List) {
        return (response['data'] as List)
            .map((e) => GiftEventModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> purchaseGift(String giftId) async {
    try {
      final response = await _api.post('${ApiConstants.gifts}/purchase', body: {
        'giftId': giftId,
      });
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}
