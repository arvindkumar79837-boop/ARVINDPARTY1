// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/shop/presentation/views/shop_screen.dart
// ARVIND PARTY - SHOP SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/shop_controller.dart';

class ShopScreen extends GetView<ShopController> {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            // ─── Category Filter Chips ──────────────────────────────
            Obx(() {
              if (controller.categories.isEmpty) return const SizedBox.shrink();
              return Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: controller.categories.map((cat) {
                    final isSelected = controller.selectedCategory.value == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat, style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        )),
                        selected: isSelected,
                        selectedColor: const Color(0xFFFF8906),
                        backgroundColor: const Color(0xFF1A1A2E),
                        side: BorderSide.none,
                        onSelected: (_) => controller.setCategory(cat),
                      ),
                    );
                  }).toList(),
                ),
              );
            }),

            // ─── Items Grid ─────────────────────────────────────────
            Expanded(
              child: controller.filteredItems.isEmpty
                  ? const Center(child: Text('No items in this category', style: TextStyle(color: Colors.grey)))
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: controller.filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = controller.filteredItems[index];
                        return _ShopItemCard(
                          item: item,
                          isPurchasing: controller.isPurchasing.value,
                          onBuy: () {
                            Get.defaultDialog(
                              title: 'Confirm Purchase',
                              middleText: 'Buy ${item['name']} for ${item['priceDiamonds']} diamonds?',
                              textConfirm: 'Buy',
                              textCancel: 'Cancel',
                              confirmTextColor: Colors.white,
                              buttonColor: const Color(0xFFFF8906),
                              onConfirm: () {
                                Get.back();
                                controller.purchaseItem(
                                  item['_id'] as String? ?? '',
                                  item['name'] as String? ?? '',
                                  item['priceDiamonds'] as int? ?? 0,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }
}

class _ShopItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isPurchasing;
  final VoidCallback onBuy;

  const _ShopItemCard({
    required this.item,
    required this.isPurchasing,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final name = item['name'] as String? ?? '';
    final type = item['type'] as String? ?? 'frame';
    final price = item['priceDiamonds'] as int? ?? 0;
    final days = item['durationDays'] as int? ?? 7;

    IconData icon;
    Color color;
    switch (type) {
      case 'frame':
        icon = Icons.filter_frames;
        color = const Color(0xFFFF8906);
        break;
      case 'mount':
        icon = Icons.directions_car;
        color = const Color(0xFFE91E63);
        break;
      case 'bubble':
        icon = Icons.chat_bubble;
        color = const Color(0xFF2196F3);
        break;
      default:
        icon = Icons.card_giftcard;
        color = Colors.grey;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.2), const Color(0xFF1A1A2E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text('$price 💎', style: const TextStyle(fontSize: 14, color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
          Text('$days days', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            height: 30,
            child: ElevatedButton(
              onPressed: isPurchasing ? null : onBuy,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: isPurchasing
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Buy', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
