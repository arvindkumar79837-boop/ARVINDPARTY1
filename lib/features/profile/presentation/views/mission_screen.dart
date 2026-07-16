import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MissionScreen extends StatelessWidget {
  const MissionScreen({super.key});

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
        title: const Text('Daily Missions', style: TextStyle(color: Colors.white, fontSize: 20)),
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              _buildProgressHeader(),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const TabBar(
                  indicatorColor: Colors.amber,
                  labelColor: Colors.amber,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  tabs: [
                    Tab(text: 'Daily'),
                    Tab(text: 'Weekly'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildMissionsList(isDaily: true),
                    _buildMissionsList(isDaily: false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
        border: Border.all(color: Colors.amber.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.amber, Colors.orange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.emoji_events_outlined, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mission Progress', style: TextStyle(fontSize: 12, color: Colors.white70)),
                    SizedBox(height: 2),
                    Text('3 / 5 Completed', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.6,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '60% complete — 150 🪙 earned',
                style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
              ),
              Text(
                'Next: 25 🪙',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.amber.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMissionsList({required bool isDaily}) {
    final dailyMissions = [
      {'title': 'Login to the app', 'desc': 'Open the app once today', 'reward': 10, 'progress': 1.0, 'icon': Icons.login, 'color': Colors.green, 'completed': true},
      {'title': 'Send 5 messages', 'desc': 'Send messages in any chat room', 'reward': 20, 'progress': 0.6, 'icon': Icons.chat_bubble_outline, 'color': Colors.blue, 'completed': false},
      {'title': 'Join a live room', 'desc': 'Spend 5 minutes in a live room', 'reward': 30, 'progress': 1.0, 'icon': Icons.live_tv, 'color': Colors.red, 'completed': true},
      {'title': 'Send a gift', 'desc': 'Send any gift to a host', 'reward': 50, 'progress': 0.0, 'icon': Icons.card_giftcard_outlined, 'color': Colors.pink, 'completed': false},
      {'title': 'Stay for 30 minutes', 'desc': 'Active usage for 30 min total', 'reward': 40, 'progress': 1.0, 'icon': Icons.access_time, 'color': Colors.orange, 'completed': true},
      {'title': 'Follow a new host', 'desc': 'Discover and follow a new host', 'reward': 15, 'progress': 0.0, 'icon': Icons.person_add_outlined, 'color': Colors.teal, 'completed': false},
    ];

    final weeklyMissions = [
      {'title': 'Login 7 days straight', 'desc': 'Daily login streak this week', 'reward': 100, 'progress': 0.71, 'icon': Icons.local_fire_department_outlined, 'color': Colors.deepOrange, 'completed': false},
      {'title': 'Send 50 messages', 'desc': 'Total messages this week', 'reward': 80, 'progress': 0.4, 'icon': Icons.chat_outlined, 'color': Colors.blue, 'completed': false},
      {'title': 'Join 5 live rooms', 'desc': 'Visit different live rooms', 'reward': 120, 'progress': 0.6, 'icon': Icons.live_tv, 'color': Colors.red, 'completed': false},
      {'title': 'Send 10 gifts', 'desc': 'Gift 10 different hosts', 'reward': 200, 'progress': 0.3, 'icon': Icons.card_giftcard, 'color': Colors.pink, 'completed': false},
      {'title': 'Accumulate 1000 coins', 'desc': 'Earn or spend 1000 coins total', 'reward': 150, 'progress': 0.65, 'icon': Icons.monetization_on_outlined, 'color': Colors.amber, 'completed': false},
    ];

    final missions = isDaily ? dailyMissions : weeklyMissions;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: missions.length,
      itemBuilder: (context, index) {
        final m = missions[index];
        final color = m['color'] as Color;
        final progress = m['progress'] as double;
        final completed = m['completed'] as bool;
        final reward = m['reward'] as int;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: completed ? color.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: completed ? color.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(m['icon'] as IconData, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m['title'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        decoration: completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(m['desc'] as String, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
                    if (!completed) ...[
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (completed)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.green, size: 18),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+$reward 🪙',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
