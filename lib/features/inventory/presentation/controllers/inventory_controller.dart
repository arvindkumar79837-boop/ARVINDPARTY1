// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/inventory/presentation/controllers/inventory_controller.dart
// ARVIND PARTY - INVENTORY / BACKPACK CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InventoryController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = Rxn<String>();
  final selectedTab = 0.obs;
  final sortOrder = 'recent'.obs;

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

  void loadInventory() {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      // TODO: Replace hardcoded items with API call to _repo.getInventory()
      frames.value = [
        InventoryItem('frame_001', 'Gold Frame', 'frame', 'Premium Gold', 'common',
            DateTime.now().add(const Duration(days: 30)), true),
        InventoryItem('frame_002', 'Neon Frame', 'frame', 'Neon Blue', 'rare',
            DateTime.now().add(const Duration(days: 60)), true),
        InventoryItem('frame_003', 'Diamond Frame', 'frame', 'Diamond Elite', 'legendary',
            DateTime.now().add(const Duration(days: 90)), true),
        InventoryItem('frame_004', 'Silver Frame', 'frame', 'Classic Silver', 'uncommon',
            DateTime.now().add(const Duration(days: 15)), false),
        InventoryItem('frame_005', 'Rose Gold', 'frame', 'Valentine Special', 'rare',
            DateTime.now().add(const Duration(days: 7)), false),
        InventoryItem('frame_006', 'Party Frame', 'frame', 'Arvind Party', 'epic',
            DateTime.now().add(const Duration(days: 45)), false),
      ];

      badges.value = [
        InventoryItem('badge_001', 'VIP Badge', 'badge', 'VIP Member', 'legendary',
            DateTime.now().add(const Duration(days: 365)), true),
        InventoryItem('badge_002', 'Top Host', 'badge', 'Best Host Award', 'epic',
            DateTime.now().add(const Duration(days: 180)), false),
        InventoryItem('badge_003', 'Party Animal', 'badge', '100 Parties', 'rare',
            DateTime.now().add(const Duration(days: 90)), true),
        InventoryItem('badge_004', 'Gift Master', 'badge', '1000 Gifts Sent', 'epic',
            DateTime.now().add(const Duration(days: 120)), false),
        InventoryItem('badge_005', 'Early Adopter', 'badge', 'Joined Beta', 'legendary',
            DateTime.now().add(const Duration(days: 730)), false),
      ];

      entryEffects.value = [
        InventoryItem('effect_001', 'Fireworks', 'entryEffect', 'Spectacular Entry', 'epic',
            DateTime.now().add(const Duration(days: 30)), true),
        InventoryItem('effect_002', 'Confetti Storm', 'entryEffect', 'Party Confetti', 'rare',
            DateTime.now().add(const Duration(days: 45)), false),
        InventoryItem('effect_003', 'Neon Glow', 'entryEffect', 'Neon Entrance', 'uncommon',
            DateTime.now().add(const Duration(days: 20)), false),
        InventoryItem('effect_004', 'Starlight', 'entryEffect', 'Elegant Sparkle', 'common',
            DateTime.now().add(const Duration(days: 60)), false),
        InventoryItem('effect_005', 'Dragon Fire', 'entryEffect', 'Mythical Entry', 'legendary',
            DateTime.now().add(const Duration(days: 90)), false),
      ];

      bubbles.value = [
        InventoryItem('bubble_001', 'Heart Bubble', 'bubble', 'Love Chat', 'rare',
            DateTime.now().add(const Duration(days: 30)), true),
        InventoryItem('bubble_002', 'Neon Bubble', 'bubble', 'Cyber Style', 'epic',
            DateTime.now().add(const Duration(days: 45)), false),
        InventoryItem('bubble_003', 'Star Bubble', 'bubble', 'Galaxy Chat', 'uncommon',
            DateTime.now().add(const Duration(days: 15)), false),
      ];

      allItems.value = [
        ...frames,
        ...badges,
        ...entryEffects,
        ...bubbles,
        ...cars,
      ];

      equippedFrame.value = frames.firstWhereOrNull((f) => f.isEquipped);
      equippedBadge.value = badges.firstWhereOrNull((b) => b.isEquipped);
      equippedEntryEffect.value = entryEffects.firstWhereOrNull((e) => e.isEquipped);
      equippedBubble.value = bubbles.firstWhereOrNull((b) => b.isEquipped);
    } catch (e) {
      errorMessage.value = 'Failed to load inventory: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void equipItem(InventoryItem item) {
    try {
      if (item.isEquipped) return;

      // Unequip previous item in same category
      switch (item.category) {
        case 'frame':
          if (equippedFrame.value != null) {
            _setEquipped(equippedFrame.value!, false);
          }
          equippedFrame.value = item;
          break;
        case 'badge':
          if (equippedBadge.value != null) {
            _setEquipped(equippedBadge.value!, false);
          }
          equippedBadge.value = item;
          break;
        case 'entryEffect':
          if (equippedEntryEffect.value != null) {
            _setEquipped(equippedEntryEffect.value!, false);
          }
          equippedEntryEffect.value = item;
          break;
        case 'bubble':
          if (equippedBubble.value != null) {
            _setEquipped(equippedBubble.value!, false);
          }
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

  void unequipItem(InventoryItem item) {
    try {
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
}

class InventoryItem {
  final String id;
  final String name;
  final String category; // frame, badge, entryEffect, bubble, car
  final String description;
  final String rarity; // common, uncommon, rare, epic, legendary
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