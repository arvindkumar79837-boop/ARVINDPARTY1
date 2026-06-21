// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/inventory/presentation/views/inventory_screen.dart
// ARVIND PARTY - INVENTORY / BACKPACK SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/inventory_controller.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final InventoryController controller = Get.find<InventoryController>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Backpack',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          Obx(() => PopupMenuButton<String>(
                icon: const Icon(Icons.sort, color: Colors.white70),
                onSelected: controller.setSortOrder,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'recent',
                    child: Row(
                      children: [
                        Icon(Icons.access_time, size: 18, color: controller.sortOrder.value == 'recent' ? const Color(0xFFFF9800) : Colors.white70),
                        const SizedBox(width: 8),
                        Text('Recent', style: TextStyle(color: controller.sortOrder.value == 'recent' ? const Color(0xFFFF9800) : Colors.white70)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'rarity',
                    child: Row(
                      children: [
                        Icon(Icons.star, size: 18, color: controller.sortOrder.value == 'rarity' ? const Color(0xFFFF9800) : Colors.white70),
                        const SizedBox(width: 8),
                        Text('Rarity', style: TextStyle(color: controller.sortOrder.value == 'rarity' ? const Color(0xFFFF9800) : Colors.white70)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'name',
                    child: Row(
                      children: [
                        Icon(Icons.sort_by_alpha, size: 18, color: controller.sortOrder.value == 'name' ? const Color(0xFFFF9800) : Colors.white70),
                        const SizedBox(width: 8),
                        Text('Name', style: TextStyle(color: controller.sortOrder.value == 'name' ? const Color(0xFFFF9800) : Colors.white70)),
                      ],
                    ),
                  ),
                ],
              )),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF9800)));
          }
          return Column(
            children: [
              _buildEquippedSection(controller),
              _buildTabBar(controller),
              Expanded(child: _buildTabContent(controller)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildEquippedSection(InventoryController controller) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A4E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF9800).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Equipped', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              Text('${controller.equippedItems}/${controller.totalItems}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildEquippedSlot(controller, 'Frame', controller.equippedFrame.value?.name ?? 'None', Icons.border_style),
                _buildEquippedSlot(controller, 'Badge', controller.equippedBadge.value?.name ?? 'None', Icons.verified),
                _buildEquippedSlot(controller, 'Entry', controller.equippedEntryEffect.value?.name ?? 'None', Icons.auto_awesome),
                _buildEquippedSlot(controller, 'Bubble', controller.equippedBubble.value?.name ?? 'None', Icons.chat_bubble),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquippedSlot(InventoryController controller, String label, String value, IconData icon) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: value != 'None' ? const Color(0xFFFF9800).withValues(alpha: 0.1) : const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: value != 'None' ? const Color(0xFFFF9800).withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, color: value != 'None' ? const Color(0xFFFF9800) : Colors.white24, size: 20),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(
            color: value != 'None' ? const Color(0xFFFF9800) : Colors.white38,
            fontSize: 9,
            fontWeight: value != 'None' ? FontWeight.w600 : FontWeight.normal,
          ), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildTabBar(InventoryController controller) {
    final tabs = ['All', 'Frames', 'Badges', 'Effects', 'Bubbles'];
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: List.generate(tabs.length, (index) {
          final isSelected = controller.selectedTab.value == index;
          return GestureDetector(
            onTap: () => controller.selectedTab.value = index,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFF9800) : const Color(0xFF2A2A4E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(tabs[index], style: TextStyle(
                color: isSelected ? Colors.black : Colors.white70,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              )),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent(InventoryController controller) {
    return Obx(() {
      final items = controller.selectedTab.value == 0
          ? controller.allItems
          : _getFilteredItems(controller);
      if (items.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 64, color: Colors.white.withValues(alpha: 0.2)),
              const SizedBox(height: 16),
              const Text('No items found', style: TextStyle(color: Colors.white54)),
            ],
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (context, index) => _buildItemCard(controller, items[index]),
      );
    });
  }

  List<dynamic> _getFilteredItems(InventoryController controller) {
    switch (controller.selectedTab.value) {
      case 1: return controller.frames;
      case 2: return controller.badges;
      case 3: return controller.entryEffects;
      case 4: return controller.bubbles;
      default: return controller.allItems;
    }
  }

  Widget _buildItemCard(InventoryController controller, InventoryItem item) {
    final daysLeft = item.expiresAt.difference(DateTime.now()).inDays;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: item.isEquipped ? const Color(0xFFFF9800).withValues(alpha: 0.08) : const Color(0xFF2A2A4E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.isEquipped
              ? const Color(0xFFFF9800).withValues(alpha: 0.3)
              : item.rarityColor.withValues(alpha: 0.2),
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: item.rarityColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: item.rarityColor.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              item.name.substring(0, 1).toUpperCase(),
              style: TextStyle(color: item.rarityColor, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),
        title: Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: item.rarityColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(item.rarity.toUpperCase(), style: TextStyle(color: item.rarityColor, fontSize: 9, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            Text(
              daysLeft > 0 ? '${daysLeft}d left' : 'Expiring soon',
              style: TextStyle(color: daysLeft < 3 ? Colors.red : Colors.white.withValues(alpha: 0.4), fontSize: 11),
            ),
          ],
        ),
        trailing: item.isEquipped
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Equipped', style: TextStyle(color: Color(0xFFFF9800), fontSize: 11, fontWeight: FontWeight.w600)),
              )
            : ElevatedButton(
                onPressed: () => controller.equipItem(item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text('Equip', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
      ),
    );
  }
}