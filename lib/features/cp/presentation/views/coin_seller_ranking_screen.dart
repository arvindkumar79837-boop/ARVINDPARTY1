import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CoinSellerRankingScreen extends StatelessWidget {
  const CoinSellerRankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('Seller Rankings', style: TextStyle(color: Colors.white, fontSize: 20)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopThreePodium(),
            const SizedBox(height: 16),
            _buildPeriodSelector(),
            const SizedBox(height: 12),
            Expanded(child: _buildRankingList()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopThreePodium() {
    final topThree = [
      {'rank': 1, 'name': 'GoldMart', 'sales': '₹1,85,000', 'orders': 342, 'color': Colors.amber},
      {'rank': 2, 'name': 'CoinKing', 'sales': '₹1,42,000', 'orders': 278, 'color': Colors.grey},
      {'rank': 3, 'name': 'SuperCoin', 'sales': '₹1,18,000', 'orders': 215, 'color': Colors.orange},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withValues(alpha: 0.12),
            Colors.orange.withValues(alpha: 0.06),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _buildPodiumItem(topThree[1], height: 80)),
          const SizedBox(width: 12),
          Expanded(child: _buildPodiumItem(topThree[0], height: 110)),
          const SizedBox(width: 12),
          Expanded(child: _buildPodiumItem(topThree[2], height: 65)),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(Map<String, dynamic> item, {required double height}) {
    final color = item['color'] as Color;
    final rank = item['rank'] as int;

    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: color.withValues(alpha: 0.2),
          child: Text(
            (item['name'] as String)[0],
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ),
        const SizedBox(height: 6),
        Text(item['name'] as String,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text(item['sales'] as String, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.08)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text('#$rank', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ['Weekly', 'Monthly', 'All Time'];
    final selected = 'Monthly'.obs;

    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: periods.map((period) {
              final isSelected = selected.value == period;
              return Expanded(
                child: GestureDetector(
                  onTap: () => selected.value = period,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.amber.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? Colors.amber.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        period,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? Colors.amber : Colors.white54,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ));
  }

  Widget _buildRankingList() {
    final rankings = [
      {'rank': 4, 'name': 'QuickRecharge', 'sales': '₹95,000', 'orders': 180, 'color': Colors.teal},
      {'rank': 5, 'name': 'CoinZone', 'sales': '₹82,500', 'orders': 156, 'color': Colors.blue},
      {'rank': 6, 'name': 'TopUp Pro', 'sales': '₹71,000', 'orders': 132, 'color': Colors.purple},
      {'rank': 7, 'name': 'FastCoins', 'sales': '₹65,200', 'orders': 118, 'color': Colors.pink},
      {'rank': 8, 'name': 'CoinHub', 'sales': '₹54,800', 'orders': 98, 'color': Colors.cyan},
      {'rank': 9, 'name': 'MegaRecharge', 'sales': '₹48,000', 'orders': 85, 'color': Colors.lime},
      {'rank': 10, 'name': 'EasyCoin', 'sales': '₹35,000', 'orders': 64, 'color': Colors.brown},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: rankings.length,
      itemBuilder: (context, index) {
        final r = rankings[index];
        final color = r['color'] as Color;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: Text('#${r['rank']}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
              ),
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Text((r['name'] as String)[0], style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text('${r['orders']} orders', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
                  ],
                ),
              ),
              Text(r['sales'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        );
      },
    );
  }
}
