import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vip_system_controller.dart';
import '../models/vip_system_model.dart';

class VipCosmeticsView extends GetView<VipSystemController> {
  const VipCosmeticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VIP Cosmetics', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple.shade900,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.cosmetics.isEmpty) {
          controller.fetchCosmetics();
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            _buildTypeFilter(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.fetchCosmetics(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: controller.getFilteredCosmetics().length + 1,
                  itemBuilder: (ctx, i) {
                    if (i == 0) return _buildActiveCosmeticsSection();
                    final item = controller.getFilteredCosmetics()[i - 1];
                    return _buildCosmeticItem(item);
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTypeFilter() {
    final types = ['all', 'frame', 'entrance_car', 'name_color', 'chat_bubble', 'badge'];
    final labels = {
      'all': 'All',
      'frame': 'Frames',
      'entrance_car': 'Cars',
      'name_color': 'Colors',
      'chat_bubble': 'Bubbles',
      'badge': 'Badges',
    };
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.grey.shade900,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: types.map((type) {
            final isSelected = controller.selectedCosmeticType.value == type;
            return GestureDetector(
              onTap: () => controller.selectedCosmeticType.value = type,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.pink.shade400 : Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  labels[type]!,
                  style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActiveCosmeticsSection() {
    final status = controller.vipStatus.value;
    if (status == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade900.withValues(alpha: 0.5), Colors.deepPurple.shade900.withValues(alpha: 0.5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Currently Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: [
              _activeBadge(Icons.crop_original, 'Frame', status.activeCosmetics.frameId.isNotEmpty),
              const SizedBox(width: 8),
              _activeBadge(Icons.directions_car, 'Car', status.activeCosmetics.entranceCarId.isNotEmpty),
              const SizedBox(width: 8),
              _activeBadge(Icons.palette, 'Color', status.activeCosmetics.nameColor != '#FFFFFF'),
              const SizedBox(width: 8),
              _activeBadge(Icons.chat_bubble, 'Bubble', status.activeCosmetics.chatBubbleId.isNotEmpty),
            ],
          ),
        ],
      ),
    );
  }

  Widget _activeBadge(IconData icon, String label, bool isActive) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.green.withValues(alpha: 0.2) : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isActive ? Colors.green.shade400 : Colors.transparent),
        ),
        child: Column(
          children: [
            Icon(icon, color: isActive ? Colors.green : Colors.grey, size: 20),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isActive ? Colors.green.shade300 : Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildCosmeticItem(CosmeticShopItem item) {
    final isOwned = item.isOwned;
    final canAccess = item.canAccess;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOwned ? Colors.green.shade400 : canAccess ? item.rarityColor.withValues(alpha: 0.3) : Colors.grey.shade700,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: item.rarityColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(item.typeIcon, color: item.rarityColor, size: 22),
        ),
        title: Text(item.itemName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(
          '${item.rarity.toUpperCase()} • ${item.coinCost > 0 ? '${item.coinCost.toInt()} 🪙' : 'Free'}',
          style: TextStyle(color: item.rarityColor, fontSize: 11),
        ),
        trailing: isOwned
            ? GestureDetector(
                onTap: () => controller.applyCosmetic(item.itemId, item.itemType),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Apply', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              )
            : canAccess
                ? GestureDetector(
                    onTap: () => controller.purchaseCosmetic(item.itemId),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade700,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.monetization_on, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text('${item.coinCost.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  )
                : const Icon(Icons.lock, color: Colors.grey, size: 20),
      ),
    );
  }
}