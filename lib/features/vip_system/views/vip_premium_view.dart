import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vip_system_controller.dart';

class PremiumView extends GetView<VipSystemController> {
  const PremiumView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Subscription', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple.shade900,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        final status = controller.vipStatus.value;
        final isPremium = status?.isPremium ?? false;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildPremiumHeader(isPremium, status?.premiumDaysRemaining ?? 0),
              const SizedBox(height: 24),
              _buildBenefits(),
              const SizedBox(height: 24),
              if (!isPremium) _buildPurchaseOptions(),
              if (isPremium) _buildActiveActions(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPremiumHeader(bool isActive, int daysRemaining) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [Colors.purple.shade600, Colors.deepPurple.shade900]
              : [Colors.grey.shade800, Colors.grey.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? Colors.purple.shade400 : Colors.grey.shade700, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(
            isActive ? Icons.verified : Icons.star_border,
            size: 64,
            color: isActive ? Colors.amber : Colors.grey,
          ),
          const SizedBox(height: 12),
          Text(
            isActive ? 'Premium Active' : 'Go Premium',
            style: TextStyle(
              color: isActive ? Colors.amber : Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (isActive)
            Column(
              children: [
                Text(
                  '$daysRemaining days remaining',
                  style: TextStyle(color: Colors.purple.shade200, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Expires: ${_formatDate(controller.vipStatus.value?.premiumExpiry)}',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ],
            )
          else
            Text('500 coins/month', style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildBenefits() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Premium Benefits', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        _benefitCard(Icons.card_giftcard, 'Daily Bonus', 'Get 50 coins + 10 VIP XP every day', Colors.purple),
        const SizedBox(height: 8),
        _benefitCard(Icons.verified, 'Premium Badge', 'Exclusive ⭐ Premium tag on your profile', Colors.amber),
        const SizedBox(height: 8),
        _benefitCard(Icons.crop_original, 'Premium Frames', 'Access to premium-exclusive animated frames', Colors.pink),
        const SizedBox(height: 8),
        _benefitCard(Icons.emoji_emotions, 'Exclusive Emotes', 'Special emojis only for premium users', Colors.orange),
        const SizedBox(height: 8),
        _benefitCard(Icons.fast_forward, 'VIP XP Boost', 'Earn XP faster with premium bonus', Colors.green),
      ],
    );
  }

  Widget _benefitCard(IconData icon, String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(description, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose Duration', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        _durationOption(1, 500),
        const SizedBox(height: 8),
        _durationOption(3, 1350), // 10% discount
        const SizedBox(height: 8),
        _durationOption(6, 2400), // 20% discount
        const SizedBox(height: 8),
        _durationOption(12, 4200), // 30% discount
      ],
    );
  }

  Widget _durationOption(int months, int price) {
    final discount = months > 1 ? ((1 - (price / (500 * months))) * 100).round() : 0;
    return Obx(() {
      final isSelected = controller.premiumMonths.value == months;
      return GestureDetector(
        onTap: () => controller.premiumMonths.value = months,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.purple.shade900.withValues(alpha: 0.4) : Colors.grey.shade900,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.purple.shade400 : Colors.grey.shade700,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('$months Month${months > 1 ? 's' : ''}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        if (discount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('-$discount%', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '$price coins total',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: Colors.purple, size: 24)
              else
                Radio<String>(
                  value: months.toString(),
                  groupValue: controller.premiumMonths.value.toString(),
                  onChanged: (v) => controller.premiumMonths.value = months,
                  fillColor: WidgetStateProperty.all(Colors.purple.shade300),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildActiveActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Premium Actions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => controller.claimDailyBonus(),
            icon: const Icon(Icons.card_giftcard),
            label: const Text('Claim Daily Bonus (50 Coins + 10 XP)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => controller.cancelAutoRenew(),
            icon: const Icon(Icons.cancel_schedule_send),
            label: const Text('Cancel Auto-Renew'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              side: const BorderSide(color: Colors.orange),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }
}