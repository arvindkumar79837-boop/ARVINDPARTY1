import 'package:flutter/material.dart';

class VIPScreen extends StatelessWidget {
  const VIPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('VIP Membership', style: TextStyle(color: Colors.white, fontSize: 20)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCurrentVIPCard(),
              const SizedBox(height: 24),
              _buildVIPBenefits(),
              const SizedBox(height: 24),
              _buildVIPLevels(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentVIPCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withValues(alpha: 0.2),
            Colors.orange.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        children: [
          const Icon(Icons.workspace_premium, color: Colors.amber, size: 48),
          const SizedBox(height: 12),
          const Text('VIP Level 3', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('Silver Member', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.amber)),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.55,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '3,200 / 5,800 XP to Level 4 (Gold)',
            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildVIPBenefits() {
    final benefits = [
      {'title': 'Exclusive Avatars', 'desc': 'Access to VIP-only profile frames', 'icon': Icons.face, 'color': Colors.pink},
      {'title': 'Bonus Coins', 'desc': '10% extra on every recharge', 'icon': Icons.monetization_on, 'color': Colors.amber},
      {'title': 'Priority Support', 'desc': '24/7 dedicated support team', 'icon': Icons.headset_mic, 'color': Colors.blue},
      {'title': 'Ad Free', 'desc': 'No advertisements in the app', 'icon': Icons.block, 'color': Colors.green},
      {'title': 'Special Events', 'desc': 'Access to VIP-only events', 'icon': Icons.star, 'color': Colors.purple},
      {'title': 'Gift Discounts', 'desc': '5% discount on all gifts', 'icon': Icons.card_giftcard, 'color': Colors.orange},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Benefits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        ...benefits.map((b) {
          final color = b['color'] as Color;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.15)),
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
                  child: Icon(b['icon'] as IconData, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b['title'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text(b['desc'] as String, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
                    ],
                  ),
                ),
                Icon(Icons.check_circle, color: color, size: 20),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildVIPLevels() {
    final levels = [
      {'level': 1, 'name': 'Bronze', 'xp': '0 - 1,000', 'color': Colors.brown, 'current': false},
      {'level': 2, 'name': 'Copper', 'xp': '1,001 - 3,000', 'color': Colors.orange, 'current': false},
      {'level': 3, 'name': 'Silver', 'xp': '3,001 - 5,800', 'color': Colors.grey, 'current': true},
      {'level': 4, 'name': 'Gold', 'xp': '5,801 - 10,000', 'color': Colors.amber, 'current': false},
      {'level': 5, 'name': 'Platinum', 'xp': '10,001 - 20,000', 'color': Colors.cyan, 'current': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('VIP Levels', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        ...levels.map((l) {
          final color = l['color'] as Color;
          final isCurrent = l['current'] as bool;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isCurrent ? color.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCurrent ? color.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.08),
                width: isCurrent ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text('V${l['level']}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l['name'] as String, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
                      Text(l['xp'] as String, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
                    ],
                  ),
                ),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Current', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
                  )
                else
                  Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.3), size: 20),
              ],
            ),
          );
        }),
      ],
    );
  }
}
