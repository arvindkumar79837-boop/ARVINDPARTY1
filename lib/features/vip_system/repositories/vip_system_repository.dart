import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/utils/api_exception.dart';
import '../models/vip_system_model.dart';

class VipSystemRepository {
  final _api = Get.find<ApiService>();
  final _storage = GetStorage();

  Map<String, dynamic> get _authHeaders => {
    'Authorization': 'Bearer ${_storage.read('token') ?? ''}',
  };

  Future<VipSystemStatus> getVipStatus() async {
    try {
      final response = await _api.get(
        '/vip-system/status',
        options: Options(headers: _authHeaders),
      );
      final data = response;
      if (data['success'] == true) {
        return VipSystemStatus.fromJson(data['data']);
      }
      throw Exception(data['message'] ?? 'Failed to fetch VIP status');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> addVipXP(int amount, {String source = 'bonus', String description = ''}) async {
    try {
      final response = await _api.post(
        '/vip-system/xp/add',
        data: {'amount': amount, 'source': source, 'description': description},
        options: Options(headers: _authHeaders),
      );
      return response;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> purchasePremium(int months) async {
    try {
      final response = await _api.post(
        '/vip-system/premium/purchase',
        data: {'months': months},
        options: Options(headers: _authHeaders),
      );
      return response;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> cancelPremiumAutoRenew() async {
    try {
      final response = await _api.post(
        '/vip-system/premium/cancel-renew',
        options: Options(headers: _authHeaders),
      );
      return response;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> claimPremiumDailyBonus() async {
    try {
      final response = await _api.post(
        '/vip-system/premium/daily-bonus',
        options: Options(headers: _authHeaders),
      );
      return response;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<List<CosmeticShopItem>> getAvailableCosmetics({String? itemType}) async {
    try {
      final queryParams = itemType != null ? {'item_type': itemType} : null;
      final response = await _api.get(
        '/vip-system/cosmetics',
        queryParameters: queryParams,
        options: Options(headers: _authHeaders),
      );
      final data = response;
      if (data['success'] == true) {
        return (data['data'] as List)
            .map((e) => CosmeticShopItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to fetch cosmetics');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> purchaseCosmetic(String itemId) async {
    try {
      final response = await _api.post(
        '/vip-system/cosmetics/purchase',
        data: {'item_id': itemId},
        options: Options(headers: _authHeaders),
      );
      return response;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> applyCosmetic(String itemId, String itemType, {bool apply = true}) async {
    try {
      final response = await _api.post(
        '/vip-system/cosmetics/apply',
        data: {'item_id': itemId, 'item_type': itemType, 'apply': apply},
        options: Options(headers: _authHeaders),
      );
      return response;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<List<VipMission>> getVipMissions() async {
    try {
      final response = await _api.get(
        '/vip-system/missions',
        options: Options(headers: _authHeaders),
      );
      final data = response;
      if (data['success'] == true) {
        return (data['data']['missions'] as List)
            .map((e) => VipMission.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to fetch missions');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> updateMissionProgress(String missionId, double amount) async {
    try {
      final response = await _api.post(
        '/vip-system/missions/progress',
        data: {'mission_id': missionId, 'progress_amount': amount},
        options: Options(headers: _authHeaders),
      );
      return response;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> claimMissionReward(String missionId) async {
    try {
      final response = await _api.post(
        '/vip-system/missions/claim',
        data: {'mission_id': missionId},
        options: Options(headers: _authHeaders),
      );
      return response;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<List<CosmeticShopItem>> getVIPShopItems() async {
    try {
      final response = await _api.get(
        '/vip-system/shop',
        options: Options(headers: _authHeaders),
      );
      final data = response;
      if (data['success'] == true) {
        return (data['data'] as List)
            .map((e) => CosmeticShopItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to fetch VIP shop');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<Map<String, dynamic>> triggerVIPEntry(String roomId) async {
    try {
      final response = await _api.post(
        '/vip-system/entry',
        data: {'room_id': roomId},
        options: Options(headers: _authHeaders),
      );
      return response;
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getVIPLeaderboard({int limit = 50}) async {
    try {
      final response = await _api.get(
        '/vip-system/leaderboard',
        queryParameters: {'limit': limit},
        options: Options(headers: _authHeaders),
      );
      final data = response;
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
      throw Exception('Failed to fetch leaderboard');
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}