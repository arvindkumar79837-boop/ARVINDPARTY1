import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/premium_controller.dart';

class PremiumScreen extends GetView<PremiumController> {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8906)));
          }
          return CustomScrollView(
            slivers: [
              _buildAppBar(),
              if (controller.myIsActive.value) _buildMySubscriptionBanner(),
              _buildSectionHeader('Choose Your Tier'),
              ...controller.tiers.map((tier) => _buildTierCard(tier)),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        }),
      ),
    );
  }

  SliverToBoxAdapter _buildAppBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
              onPressed: () => Get.back(),
            ),
            const Expanded(
              child: Text('Premium Membership', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildMySubscriptionBanner() {
    final expiry = controller.myExpiresAt.value;
    final daysLeft = expiry != null ? expiry.difference(DateTime.now()).inDays : 0;
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [controller.tierColor, controller.tierColor.withOpacity(0.6)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Text(controller.tierIcon, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${controller.myTierName.value} Member', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Expires in $daysLeft days', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            if (controller.myPerks['monthlyCoins'] != null && (controller.myPerks['monthlyCoins'] as num) > 0)
              ElevatedButton(
                onPressed: () => controller.claimMonthlyCoins(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: controller.tierColor),
                child: const Text('Claim Coins', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTierCard(SubscriptionTier tier) {
    final isCurrentTier = controller.myTierName.value == tier.tierName;
    final isRoyal = tier.tierName == 'Royal';
    final tierColor = isRoyal ? const Color(0xFF9C27B0) : tier.tierName == 'Gold' ? const Color(0xFFFFB300) : const Color(0xFF90A4AE);

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isCurrentTier ? tierColor : Colors.white12, width: isCurrentTier ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [tierColor, tierColor.withOpacity(0.5)]),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Text(tier.tierName == 'Royal' ? '👑' : tier.tierName == 'Gold' ? '🥇' : '🥈', style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tier.tierName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        Text('${tier.durationDays} days', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  Text('₹${tier.priceINR.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // Perks
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tier.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(tier.description, style: const TextStyle(color: Colors.white60, fontSize: 13)),
                    ),
                  _buildPerkRow('🪙', '${tier.perks['monthlyCoins'] ?? 0} Free Coins / month'),
                  _buildPerkRow('🏷️', 'Exclusive Badge: ${tier.perks['badgeIcon'] ?? 'None'}'),
                  _buildPerkRow('✨', 'Entrance Effect: ${tier.perks['entranceEffectId'] ?? 'None'}'),
                  _buildPerkRow('🎨', 'Sticker Pack: ${tier.perks['animatedStickerPackId'] ?? 'None'}'),
                  _buildPerkRow('👥', '+${tier.perks['friendLimitBoost'] ?? 0} Friend Slots'),
                  _buildPerkRow('⚡', '${tier.perks['levelUpMultiplier'] ?? 1.0}x XP Multiplier'),
                  _buildPerkRow('🃏', 'Name Card: ${tier.perks['exclusiveNameCardId'] ?? 'None'}'),
                  _buildPerkRow('🚗', 'Vehicle Effect: ${tier.perks['luxuryVehicleEffectId'] ?? 'None'}'),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isCurrentTier ? null : () => controller.purchaseTier(tier),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCurrentTier ? Colors.white12 : tierColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        isCurrentTier ? 'Current Plan' : 'Subscribe Now',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerkRow(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14))),
          const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 16),
        ],
      ),
    );
  }
}
