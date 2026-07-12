
import 'package:arvind_party/core/constants/api_constants.dart';
import 'package:arvind_party/core/services/api_service.dart';
import 'package:arvind_party/core/socket/socket_service.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Gift {
  final String id;
  final String giftName;
  final String giftType;
  final String category;
  final int coinPrice;
  final int diamondValue;
  final String previewImageUrl;
  final bool isAvailable;
  final bool isActive;
  final bool isLucky;
  final bool isTreasure;
  final bool comboEnabled;
  final bool isLimitedEdition;
  final int sortOrder;

  Gift({
    required this.id,
    required this.giftName,
    this.giftType = 'STATIC',
    this.category = 'BASIC',
    required this.coinPrice,
    this.diamondValue = 0,
    this.previewImageUrl = '',
    this.isAvailable = true,
    this.isActive = true,
    this.isLucky = false,
    this.isTreasure = false,
    this.comboEnabled = false,
    this.isLimitedEdition = false,
    this.sortOrder = 0,
  });

  factory Gift.fromJson(Map<String, dynamic> json) {
    return Gift(
      id: json['_id'] ?? json['id'] ?? '',
      giftName: json['giftName'] ?? json['name'] ?? 'Unnamed',
      giftType: json['giftType'] ?? 'STATIC',
      category: json['category'] ?? 'BASIC',
      coinPrice: json['coinPrice'] ?? json['price'] ?? 0,
      diamondValue: json['diamondValue'] ?? 0,
      previewImageUrl: json['previewImageUrl'] ?? json['imageUrl'] ?? json['iconUrl'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
      isActive: json['isActive'] ?? true,
      isLucky: json['isLucky'] ?? false,
      isTreasure: json['isTreasure'] ?? false,
      comboEnabled: json['comboEnabled'] ?? false,
      isLimitedEdition: json['isLimitedEdition'] ?? false,
      sortOrder: json['sortOrder'] ?? 0,
    );
  }
}

class GiftsController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final SocketService _socket = Get.find<SocketService>();
  final RxList<Gift> gifts = <Gift>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchGifts();
    _setupSocketListeners();
  }

  @override
  void onClose() {
    _socket.off('live_gift_effect');
    _socket.off('gift_goal_updated');
    _socket.off('gift_deleted');
    super.onClose();
  }

  void _setupSocketListeners() {
    _socket.on('live_gift_effect', (data) {
      final event = Map<String, dynamic>.from(data);
      debugPrint('[GiftsController] Live gift effect received: ${event['giftName']}');
      Get.snackbar(
        'Gift Received',
        '${event['senderName']} sent ${event['giftName']} to ${event['receiverName']}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.deepOrange,
        colorText: Colors.white,
      );
    });

    _socket.on('gift_goal_updated', (data) {
      final event = Map<String, dynamic>.from(data);
      debugPrint('[GiftsController] Gift goal updated: ${event['title']}');
      Get.snackbar(
        'Gift Goal Updated',
        event['title'] ?? 'New goal set',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.purple,
        colorText: Colors.white,
      );
    });

    _socket.on('gift_deleted', (data) {
      final event = Map<String, dynamic>.from(data);
      final deletedId = event['_id'] ?? event['id'] ?? '';
      gifts.removeWhere((g) => g.id == deletedId);
      Get.snackbar('Synced', 'Gift deleted remotely', snackPosition: SnackPosition.BOTTOM);
    });
  }

  Future<void> fetchGifts({String? type}) async {
    try {
      isLoading.value = true;
      const endpoint = '${ApiConstants.gifts}/store';
      final query = <String, dynamic>{};
      if (type != null) query['type'] = type;

      final response = await _api.get(endpoint, query: query);
      final data = response as Map<String, dynamic>;
      if (data['success'] == true) {
        final List<dynamic> giftList = data['gifts'] ?? [];
        gifts.value = giftList.map((json) => Gift.fromJson(json)).toList();
      } else {
        Get.snackbar('Info', data['message'] ?? 'No gifts available');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch gifts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createGift({
    required String giftName,
    required int coinPrice,
    required int diamondValue,
    required String giftType,
    required String category,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      isLoading.value = true;
      final body = <String, dynamic>{
        'giftName': giftName,
        'coinPrice': coinPrice,
        'diamondValue': diamondValue,
        'giftType': giftType.toUpperCase(),
        'category': category.toUpperCase(),
        'sortOrder': 0,
        'isLucky': false,
        'isTreasure': false,
        'isAvailable': true,
        'isActive': true,
      };

      final response = await _api.post('/gifts/admin/create', body: body);
      final data = response as Map<String, dynamic>;
      if (data['success'] == true) {
        Get.back();
        Get.snackbar('Success', 'Gift created successfully');
        await fetchGifts();
      } else {
        Get.snackbar('Error', data['message'] ?? 'Failed to create gift');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create gift: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateGift(
    String id, {
    required String giftName,
    required int coinPrice,
    required int diamondValue,
    required String giftType,
    int sortOrder = 0,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      isLoading.value = true;
      final body = <String, dynamic>{
        'giftName': giftName,
        'coinPrice': coinPrice,
        'diamondValue': diamondValue,
        'giftType': giftType.toUpperCase(),
        'sortOrder': sortOrder,
      };

      final response = await _api.put('/gifts/admin/$id', body: body);
      final data = response as Map<String, dynamic>;
      if (data['success'] == true) {
        Get.back();
        Get.snackbar('Success', 'Gift updated successfully');
        await fetchGifts();
      } else {
        Get.snackbar('Error', data['message'] ?? 'Failed to update gift');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update gift: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteGift(String id) async {
    try {
      final response = await _api.delete('/gifts/admin/$id', body: {});
      final data = response as Map<String, dynamic>;
      if (data['success'] == true) {
        Get.back();
        gifts.removeWhere((gift) => gift.id == id);
        Get.snackbar('Success', 'Gift deleted successfully');
      } else {
        Get.back();
        Get.snackbar('Error', data['message'] ?? 'Failed to delete gift');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete gift: $e');
    }
  }

  Future<void> fetchGiftsByType(String giftType) async {
    fetchGifts(type: giftType);
  }

  Future<void> toggleGiftAvailability(String giftId, bool current) async {
    try {
      final response = await _api.put('/gifts/$giftId/toggle', body: {});
      final data = response as Map<String, dynamic>;
      if (data['success'] == true) {
        Get.snackbar('Updated', 'Gift ${current ? "disabled" : "enabled"}',
            backgroundColor: Colors.green, colorText: Colors.white);
        fetchGifts();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to toggle gift', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}