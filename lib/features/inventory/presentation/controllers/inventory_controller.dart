// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/inventory/presentation/controllers/inventory_controller.dart
// ARVIND PARTY - INVENTORY / BACKPACK CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_service.dart';

class InventoryController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = Rxn<String>();
  final selectedTab = 0.obs;
  final sortOrder = 'recent'.obs;

  final ApiService _apiService = Get.find<ApiService>();

  // Equipped items
  final equippedFrame = Rxn<InventoryItem>();
  final equippedBadge = Rxn<InventoryItem>();
  final equippedEntryEffect = Rxn<InventoryItem>();
  final equippedBubble = Rxn<InventoryItem>();

  // Item collections
  final frames = <InventoryItem>[].obs;
  final badges = <InventoryItem>[].obs;
  final entryEffects = <InventoryItem>[].obs;
  final bubbles = <InventoryItem>[].obs;
  final cars = <InventoryItem>[].obs;
  final allItems = <InventoryItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadInventory();
  }

  Future<void> loadInventory() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final response = await _apiService.get(ApiConstants.inventory);
      if (response is Map && response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>? ?? {};
        final itemsList = data['items'] as List<dynamic>? ?? [];
        final equipped = data['equipped'] as Map<String, dynamic>? ?? {};

        final parsedItems = itemsList.map((item) {
          final map = Map<String, dynamic>.from(item);
          return InventoryItem(
            map['_id'] ?? map['id'] ?? '',
            map['name'] ?? '',
            map['category'] ?? 'frame',
            map['description'] ?? '',
            map['rarity'] ?? 'common',
            map['expiresAt'] != null ? DateTime.tryParse(map['expiresAt'].toString()) ?? DateTime.now().add(const Duration(days: 30)) : DateTime.now().add(const Duration(days: 30)),
            map['isEquipped'] ?? false,
          );
        }).toList();

        frames.value = parsedItems.where((i) => i.category == 'frame').toList();
        badges.value = parsedItems.where((i) => i.category == 'badge').toList();
        entryEffects.value = parsedItems.where((i) => i.category == 'entryEffect').toList();
        bubbles.value = parsedItems.where((i) => i.category == 'bubble').toList();
        cars.value = parsedItems.where((i) => i.category == 'car').toList();

        allItems.value = [...frames, ...badges, ...entryEffects, ...bubbles, ...cars];

        if (equipped.isNotEmpty) {
          equippedFrame.value = _findItemById(frames, equipped['frame']);
          equippedBadge.value = _findItemById(badges, equipped['badge']);
          equippedEntryEffect.value = _findItemById(entryEffects, equipped['entryEffect']);
          equippedBubble.value = _findItemById(bubbles, equipped['bubble']);
        } else {
          equippedFrame.value = frames.firstWhereOrNull((f) => f.isEquipped);
          equippedBadge.value = badges.firstWhereOrNull((b) => b.isEquipped);
          equippedEntryEffect.value = entryEffects.firstWhereOrNull((e) => e.isEquipped);
          equippedBubble.value = bubbles.firstWhereOrNull((b) => b.isEquipped);
        }
      } else {
        errorMessage.value = response['message'] ?? 'Failed to load inventory';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load inventory: $e';
    } finally {
      isLoading.value = false;
    }
  }

  InventoryItem? _findItemById(List<InventoryItem> list, dynamic id) {
    if (id == null) return null;
    final idStr = id.toString();
    return list.firstWhereOrNull((i) => i.id == idStr);
  }

  Future<void> equipItem(InventoryItem item) async {
    try {
      if (item.isEquipped) return;

      final response = await _apiService.post('${ApiConstants.inventory}/equip', body: {
        'itemId': item.id,
        'category': item.category,
      });

      if (response is Map && response['success'] == true) {
        switch (item.category) {
          case 'frame':
            if (equippedFrame.value != null) _setEquipped(equippedFrame.value!, false);
            equippedFrame.value = item;
            break;
          case 'badge':
            if (equippedBadge.value != null) _setEquipped(equippedBadge.value!, false);
            equippedBadge.value = item;
            break;
          case 'entryEffect':
            if (equippedEntryEffect.value != null) _setEquipped(equippedEntryEffect.value!, false);
            equippedEntryEffect.value = item;
            break;
          case 'bubble':
            if (equippedBubble.value != null) _setEquipped(equippedBubble.value!, false);
            equippedBubble.value = item;
            break;
        }
        _setEquipped(item, true);
        allItems.refresh();
        Get.snackbar(
          'Equipped',
          '${item.name} is now active',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFF9800),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to equip item',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
      }
    } catch (e) {
      errorMessage.value = 'Failed to equip item: $e';
    }
  }

  void _setEquipped(InventoryItem item, bool equipped) {
    final index = allItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      allItems[index] = item.copyWith(isEquipped: equipped);
    }
  }

  Future<void> unequipItem(InventoryItem item) async {
    try {
      final response = await _apiService.post('${ApiConstants.inventory}/unequip', body: {
        'itemId': item.id,
        'category': item.category,
      });

      if (response is Map && response['success'] == true) {
        _setEquipped(item, false);
        switch (item.category) {
          case 'frame':
            equippedFrame.value = null;
            break;
          case 'badge':
            equippedBadge.value = null;
            break;
          case 'entryEffect':
            equippedEntryEffect.value = null;
            break;
          case 'bubble':
            equippedBubble.value = null;
            break;
        }
        allItems.refresh();
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to unequip item',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
      }
    } catch (e) {
      errorMessage.value = 'Failed to unequip item: $e';
    }
  }

  void setSortOrder(String order) {
    sortOrder.value = order;
    sortItems();
  }

  void sortItems() {
    switch (sortOrder.value) {
      case 'recent':
        allItems.sort((a, b) => b.expiresAt.compareTo(a.expiresAt));
        break;
      case 'rarity':
        allItems.sort((a, b) => _rarityWeight(b.rarity).compareTo(_rarityWeight(a.rarity)));
        break;
      case 'name':
        allItems.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
  }

  int _rarityWeight(String rarity) {
    switch (rarity) {
      case 'legendary': return 5;
      case 'epic': return 4;
      case 'rare': return 3;
      case 'uncommon': return 2;
      case 'common': return 1;
      default: return 0;
    }
  }

  List<InventoryItem> getExpiringItems({int withinDays = 7}) {
    final threshold = DateTime.now().add(Duration(days: withinDays));
    return allItems
        .where((item) => item.expiresAt.isBefore(threshold) && item.expiresAt.isAfter(DateTime.now()))
        .toList();
  }

  List<InventoryItem> getItemsByCategory(String category) {
    return allItems.where((item) => item.category == category).toList();
  }

  int get totalItems => allItems.length;
  int get equippedItems => allItems.where((i) => i.isEquipped).length;

  @override
  void onClose() {
    super.onClose();
  }
}

class InventoryItem {
  final String id;
  final String name;
  final String category;
  final String description;
  final String rarity;
  final DateTime expiresAt;
  final bool isEquipped;

  const InventoryItem(
    this.id,
    this.name,
    this.category,
    this.description,
    this.rarity,
    this.expiresAt,
    this.isEquipped,
  );

  Duration get remainingTime => expiresAt.difference(DateTime.now());

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Color get rarityColor {
    switch (rarity) {
      case 'common': return const Color(0xFF9E9E9E);
      case 'uncommon': return const Color(0xFF4CAF50);
      case 'rare': return const Color(0xFF2196F3);
      case 'epic': return const Color(0xFF9C27B0);
      case 'legendary': return const Color(0xFFFF9800);
      default: return const Color(0xFF9E9E9E);
    }
  }

  InventoryItem copyWith({bool? isEquipped}) {
    return InventoryItem(id, name, category, description, rarity, expiresAt,
        isEquipped ?? this.isEquipped);
  }
}
