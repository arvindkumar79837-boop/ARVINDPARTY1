// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/games/presentation/views/game_reward_store_screen.dart
// ARVIND PARTY - GAME REWARD STORE / SHOP
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/games_controller.dart';

class GameRewardStoreScreen extends StatelessWidget {
  const GameRewardStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GamesController>();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'Reward Store',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.orange,
            labelColor: Colors.orange,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Avatars'),
              Tab(text: 'Badges'),
              Tab(text: 'Power-ups'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              _buildStoreTab(controller, category: 'all'),
              _buildStoreTab(controller, category: 'avatars'),
              _buildStoreTab(controller, category: 'badges'),
              _buildStoreTab(controller, category: 'powerups'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreTab(GamesController controller, {required String category}) {
    final items = _getRewardItems(category);

    return Column(
      children: [
        _buildUserPointsCard(controller),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildRewardCard(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserPointsCard(GamesController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.2),
            Colors.deepOrange.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.orange, Colors.deepOrange],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.stars_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Points',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                Obx(() => Text(
                      '${controller.balance.value?['points'] ?? 350} pts',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.add_circle_outline, size: 14, color: Colors.green),
                SizedBox(width: 4),
                Text(
                  'Earn More',
                  style: TextStyle(fontSize: 12, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(Map<String, dynamic> item) {
    final isOwned = item['owned'] as bool;
    final isPremium = item['premium'] as bool;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (item['color'] as Color).withValues(alpha: 0.15),
            (item['color'] as Color).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPremium
              ? Colors.amber.withValues(alpha: 0.4)
              : (item['color'] as Color).withValues(alpha: 0.25),
          width: isPremium ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (item['color'] as Color).withValues(alpha: 0.3),
                    (item['color'] as Color).withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      item['icon'] as IconData,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  if (isPremium)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.stars_outlined,
                          size: 12,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item['price']} pts',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    if (isOwned)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Owned',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Buy',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getRewardItems(String category) {
    final allItems = [
      {'name': 'Golden Crown', 'icon': Icons.emoji_events_outlined, 'color': Colors.amber, 'price': 500, 'category': 'badges', 'owned': true, 'premium': true},
      {'name': 'Fire Avatar', 'icon': Icons.local_fire_department_outlined, 'color': Colors.deepOrange, 'price': 300, 'category': 'avatars', 'owned': false, 'premium': false},
      {'name': 'Lucky Charm', 'icon': Icons.lightbulb_outlined, 'color': Colors.purple, 'price': 150, 'category': 'powerups', 'owned': false, 'premium': false},
      {'name': 'Ice Shield', 'icon': Icons.ac_unit_outlined, 'color': Colors.lightBlue, 'price': 250, 'category': 'powerups', 'owned': true, 'premium': false},
      {'name': 'Diamond Badge', 'icon': Icons.diamond_outlined, 'color': Colors.cyan, 'price': 800, 'category': 'badges', 'owned': false, 'premium': true},
      {'name': 'Neon Frame', 'icon': Icons.border_style_outlined, 'color': Colors.pink, 'price': 400, 'category': 'avatars', 'owned': false, 'premium': false},
      {'name': 'Turbo Boost', 'icon': Icons.speed_outlined, 'color': Colors.red, 'price': 200, 'category': 'powerups', 'owned': false, 'premium': false},
      {'name': 'Star Badge', 'icon': Icons.star_outlined, 'color': Colors.amber, 'price': 350, 'category': 'badges', 'owned': true, 'premium': false},
    ];

    if (category == 'all') return allItems;
    return allItems.where((item) => item['category'] == category).toList();
  }
}