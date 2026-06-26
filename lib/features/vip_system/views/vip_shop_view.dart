import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vip_system_controller.dart';
import '../models/vip_system_model.dart';

class VipShopView extends GetView<VipSystemController> {
  const VipShopView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VIP Shop', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple.shade900,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.shopItems.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            _buildCategoryFilter(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.fetchShopItems,
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: controller.getFilteredShopItems().length,
                  itemBuilder: (ctx, i) => _buildShopItemCard(controller.getFilteredShopItems()[i]),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['all', 'frame', 'entrance_car', 'name_color', 'chat_bubble', 'badge'];
    final icons = {
      'all': Icons.apps,
      'frame': Icons.crop_original,
      'entrance_car': Icons.directions_car,
      'name_color': Icons.palette,
      'chat_bubble': Icons.chat_bubble,
      'badge': Icons.verified,
    };
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.grey.shade900,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: categories.map((cat) {
            final isSelected = controller.selectedShopCategory.value == cat;
            return GestureDetector(
              onTap: () => controller.selectedShopCategory.value = cat,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.amber.shade700 : Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icons[cat], size: 16, color: isSelected ? Colors.black : Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      cat == 'all' ? 'All' : cat.replaceAll('_', ' ').capitalizeFirst!,
                      style: TextStyle(color: isSelected ? Colors.black : Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildShopItemCard(CosmeticShopItem item) {
    return GestureDetector(
      onTap: () => _showItemDetail(item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isOwned ? Colors.green.shade400 : item.rarityColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: item.rarityColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.typeIcon, color: item.rarityColor, size: 28),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                item.itemName,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: item.rarityColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                item.rarity.toUpperCase(),
                style: TextStyle(color: item.rarityColor, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 6),
            if (item.isOwned)
              const Icon(Icons.check_circle, color: Colors.green, size: 20)
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${item.coinCost.toInt()}',
                    style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showItemDetail(CosmeticShopItem item) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade600, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: item.rarityColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(item.typeIcon, color: item.rarityColor, size: 40),
            ),
            const SizedBox(height: 12),
            Text(item.itemName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(item.description, style: TextStyle(color: Colors.grey.shade400, fontSize: 13), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: item.rarityColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(item.rarity.toUpperCase(), style: TextStyle(color: item.rarityColor, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(height: 16),
            if (item.vipLevelRequired > 0)
              _detailRow('VIP Required', 'Level ${item.vipLevelRequired}+', VipLevelHelper.getColor(item.vipLevelRequired)),
            if (item.isPremiumExclusive)
              _detailRow('Type', 'Premium Exclusive', Colors.purple),
            if (item.isSvipExclusive)
              _detailRow('Type', 'SVIP Exclusive', Colors.amber),
            if (item.isLimitedEdition)
              _detailRow('Limited', '${item.limitedEditionSold}/${item.limitedEditionQuantity}', Colors.red),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: item.isOwned
                    ? () {
                        Get.back();
                        controller.applyCosmetic(item.itemId, item.itemType);
                      }
                    : item.canAccess
                        ? () {
                            Get.back();
                            controller.purchaseCosmetic(item.itemId);
                          }
                        : null,
                icon: Icon(item.isOwned ? Icons.check_circle : Icons.shopping_cart),
                label: Text(
                  item.isOwned
                      ? 'Apply Now'
                      : item.canAccess
                          ? 'Buy ${item.coinCost.toInt()} Coins'
                          : 'Locked',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: item.isOwned ? Colors.green : item.canAccess ? Colors.amber.shade700 : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}