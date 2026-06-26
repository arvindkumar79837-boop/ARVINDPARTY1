import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vip_system_controller.dart';
import '../models/vip_system_model.dart';

class VipDashboardView extends GetView<VipSystemController> {
  const VipDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VIP Lounge', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple.shade900,
        foregroundColor: Colors.white,
        actions: [
          Obx(() => controller.isPremiumActive
              ? Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${controller.vipStatus.value?.premiumDaysRemaining ?? 0}d',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink()),
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () => Get.toNamed('/vip-leaderboard'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final status = controller.vipStatus.value;
        if (status == null) {
          return _buildNotLoggedIn();
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVIPHeader(status),
              const SizedBox(height: 16),
              _buildVIPProgress(status),
              const SizedBox(height: 16),
              _buildQuickActions(status),
              const SizedBox(height: 16),
              _buildSVIPSection(status),
              const SizedBox(height: 16),
              _buildPremiumSection(status),
              const SizedBox(height: 16),
              _buildVIPFeatures(status),
              const SizedBox(height: 16),
              _buildActiveCosmetics(status),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildNotLoggedIn() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.vpn_key, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text('Login to view VIP Status', style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Get.toNamed('/login'),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildVIPHeader(VipSystemStatus status) {
    final isSVIP = status.isSvip;
    final level = isSVIP ? status.svipLevel : status.vipLevel;
    final levelName = isSVIP ? VipLevelHelper.getSvipName(level) : VipLevelHelper.getName(level);
    final levelColor = isSVIP ? VipLevelHelper.getSvipColor(level) : VipLevelHelper.getColor(level);
    final badgeText = isSVIP ? 'SVIP $level' : 'VIP $level';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSVIP
              ? [levelColor.withValues(alpha: 0.7), Colors.black]
              : [levelColor.withValues(alpha: 0.3), Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: levelColor.withValues(alpha: 0.5), width: 1.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [levelColor, levelColor.withValues(alpha: 0.5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: levelColor, width: 2),
            ),
            child: Center(
              child: Text(
                badgeText,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isSVIP ? 14 : 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  levelName,
                  style: TextStyle(
                    color: levelColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (isSVIP) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade700,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('👑 SUPER VIP', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 4),
                ],
                if (status.isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade600,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('⭐ PREMIUM • ${status.premiumDaysRemaining}d remaining', style: const TextStyle(color: Colors.white, fontSize: 11)),
                  ),
              ],
            ),
          ),
          Column(
            children: [
              const Icon(Icons.monetization_on, color: Colors.amber, size: 28),
              Text(
                '${status.vipXp}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                'XP',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVIPProgress(VipSystemStatus status) {
    if (status.isSvip) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('VIP Progress', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                '${status.vipLevel}/15',
                style: TextStyle(color: VipLevelHelper.getColor(status.vipLevel), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: status.vipLevelProgress / 100.0,
              backgroundColor: Colors.grey.shade800,
              valueColor: AlwaysStoppedAnimation<Color>(VipLevelHelper.getColor(status.vipLevel)),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Level ${status.vipLevel}', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
              Text(
                status.vipLevel >= 15 ? 'MAX LEVEL' : '${status.vipXpToNextLevel} XP to next level',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(VipSystemStatus status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        Row(
          children: [
            _actionButton(Icons.store, 'VIP Shop', Colors.amber, () => Get.toNamed('/vip-shop')),
            const SizedBox(width: 12),
            _actionButton(Icons.flag, 'Missions', Colors.blue, () => Get.toNamed('/vip-missions')),
            const SizedBox(width: 12),
            _actionButton(Icons.palette, 'Cosmetics', Colors.pink, () => Get.toNamed('/vip-cosmetics')),
            const SizedBox(width: 12),
            _actionButton(Icons.card_giftcard, 'Premium', Colors.purple, () => Get.toNamed('/premium')),
          ],
        ),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSVIPSection(VipSystemStatus status) {
    if (!status.isSvip) return const SizedBox.shrink();
    final config = status.svipConfig;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade800.withValues(alpha: 0.3), Colors.deepOrange.shade900.withValues(alpha: 0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade700, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text('SVIP Benefits', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          if (config != null) ...[
            _svipBenefit('Monthly Coins', '${config['monthly_coins'] ?? 'N/A'} coins'),
            _svipBenefit('Name Color', config['name_color'] ?? '#FFFFFF'),
            _svipBenefit('Status', '👑 Royal Treatment'),
          ],
        ],
      ),
    );
  }

  Widget _svipBenefit(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.amber, size: 16),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: Colors.grey.shade300, fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildPremiumSection(VipSystemStatus status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: status.isPremium
              ? [Colors.purple.shade700.withValues(alpha: 0.3), Colors.deepPurple.shade900.withValues(alpha: 0.3)]
              : [Colors.grey.shade800, Colors.grey.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: status.isPremium ? Colors.purple.shade400 : Colors.grey.shade700,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(status.isPremium ? Icons.stars : Icons.star_border, color: Colors.purple.shade200, size: 20),
              const SizedBox(width: 8),
              Text(
                status.isPremium ? 'Premium Active' : 'Premium Subscription',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (status.isPremium) ...[
            _premiumBenefit('Daily Bonus', '50 coins + 10 XP'),
            _premiumBenefit('Premium Badge', '⭐ Premium Tag'),
            _premiumBenefit('Days Remaining', '${status.premiumDaysRemaining} days'),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => controller.claimDailyBonus(),
                icon: const Icon(Icons.card_giftcard, size: 16),
                label: const Text('Claim Daily Bonus'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.purple.shade200,
                  side: BorderSide(color: Colors.purple.shade400),
                ),
              ),
            ),
          ] else ...[
            _premiumBenefit('Price', '500 coins/month'),
            _premiumBenefit('Daily Bonus', '50 coins + 10 XP'),
            _premiumBenefit('Premium Badge', '⭐ Exclusive Tag'),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Get.toNamed('/premium'),
                icon: const Icon(Icons.stars, size: 16),
                label: const Text('Subscribe Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _premiumBenefit(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const Icon(Icons.check, color: Colors.purple, size: 14),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: Colors.grey.shade300, fontSize: 13)),
          const Spacer(),
          Text(value, style: TextStyle(color: Colors.purple.shade200, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildVIPFeatures(VipSystemStatus status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('VIP Powers', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        _featureCard(Icons.crop_original, 'Profile Frames', 'Animated frames around your avatar', status.activeCosmetics.frameId.isNotEmpty),
        const SizedBox(height: 8),
        _featureCard(Icons.directions_car, 'Entrance Effects', 'Show off when entering rooms', status.activeCosmetics.entranceCarId.isNotEmpty),
        const SizedBox(height: 8),
        _featureCard(Icons.palette, 'Name Color', 'Stand out in chat', status.activeCosmetics.nameColor != '#FFFFFF'),
        const SizedBox(height: 8),
        _featureCard(Icons.chat_bubble, 'Chat Bubble', 'Exclusive chat bubble style', status.activeCosmetics.chatBubbleId.isNotEmpty),
      ],
    );
  }

  Widget _featureCard(IconData icon, String title, String subtitle, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade900.withValues(alpha: 0.3) : Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.green.shade400 : Colors.grey.shade700,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isActive ? Colors.green : Colors.grey, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: isActive ? Colors.green.shade200 : Colors.white, fontWeight: FontWeight.w600)),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? Colors.green : Colors.grey.shade700,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isActive ? 'Active' : 'Inactive',
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCosmetics(VipSystemStatus status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('XP History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        ...status.xpHistory.take(5).map((entry) => Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(entry.sourceIcon, color: Colors.grey, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.description.isNotEmpty ? entry.description : entry.source,
                  style: TextStyle(color: Colors.grey.shade300, fontSize: 12),
                ),
              ),
              Text(
                '+${entry.amount.toInt()} XP',
                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
        )),
      ],
    );
  }
}