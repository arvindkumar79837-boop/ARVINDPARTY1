import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/agency_controller.dart';

class AgencyAnalyticsScreen extends StatelessWidget {
  const AgencyAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AgencyController>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('Agency Analytics', style: TextStyle(color: Colors.white, fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              controller.fetchRealtimeAnalytics();
              controller.fetchMonthlyReport();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.fetchRealtimeAnalytics();
            await controller.fetchMonthlyReport();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRealtimeStatsCard(controller),
                const SizedBox(height: 24),
                _buildGrowthMetricsSection(controller),
                const SizedBox(height: 24),
                _buildRevenueTrendSection(),
                const SizedBox(height: 24),
                _buildMemberPerformanceSection(controller),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRealtimeStatsCard(AgencyController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.teal.withValues(alpha: 0.2),
            Colors.cyan.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.35), width: 1.5),
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
                    colors: [Colors.teal, Colors.cyan],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Realtime Overview', style: TextStyle(fontSize: 13, color: Colors.white70)),
                    SizedBox(height: 2),
                    Text('Live Performance', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() {
            final analytics = controller.realtimeAnalytics.value;
            final data = analytics != null ? analytics['data'] as Map<String, dynamic>? : null;
            return Row(
              children: [
                Expanded(
                  child: _buildStatMini(
                    icon: Icons.live_tv,
                    label: 'Live Now',
                    value: '${data?['liveNow'] ?? 0}',
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatMini(
                    icon: Icons.check_circle_outline,
                    label: 'Done Today',
                    value: '${data?['doneToday'] ?? 0}',
                    color: Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatMini(
                    icon: Icons.pending_outlined,
                    label: 'Pending',
                    value: '${data?['notStarted'] ?? 0}',
                    color: Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatMini(
                    icon: Icons.people_outline,
                    label: 'Total Hosts',
                    value: '${data?['totalHosts'] ?? 0}',
                    color: Colors.purple,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatMini({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.5)), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildGrowthMetricsSection(AgencyController controller) {
    final metrics = [
      {'label': 'Active Hosts', 'value': '24', 'change': '+3', 'isPositive': true, 'color': Colors.green, 'icon': Icons.person_outline},
      {'label': 'Avg Daily Hours', 'value': '4.2h', 'change': '+0.5h', 'isPositive': true, 'color': Colors.blue, 'icon': Icons.access_time},
      {'label': 'Revenue/Host', 'value': '₹6,500', 'change': '+12%', 'isPositive': true, 'color': Colors.orange, 'icon': Icons.trending_up},
      {'label': 'Retention Rate', 'value': '89%', 'change': '-2%', 'isPositive': false, 'color': Colors.red, 'icon': Icons.group_outlined},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Growth Metrics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          itemBuilder: (context, index) {
            final m = metrics[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (m['color'] as Color).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(m['icon'] as IconData, color: m['color'] as Color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(m['label'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(m['value'] as String, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: m['color'] as Color)),
                      const SizedBox(height: 2),
                      Text(
                        m['change'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: (m['isPositive'] as bool) ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRevenueTrendSection() {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    final values = [45000.0, 52000.0, 48000.0, 61000.0, 58000.0, 67000.0];
    final maxVal = values.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Revenue Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('6 Months', style: TextStyle(fontSize: 11, color: Colors.teal, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 150,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(months.length, (i) {
                    final barHeight = (values[i] / maxVal) * 120;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '₹${(values[i] / 1000).toStringAsFixed(0)}k',
                              style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.5)),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: barHeight,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.teal.withValues(alpha: 0.8),
                                    Colors.cyan.withValues(alpha: 0.6),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(months[i], style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.6))),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMemberPerformanceSection(AgencyController controller) {
    final performers = [
      {'name': 'Rahul', 'role': 'Host', 'hours': '6.2h', 'earnings': '₹8,500', 'avatar': 'R', 'color': Colors.blue},
      {'name': 'Priya', 'role': 'Host', 'hours': '5.8h', 'earnings': '₹7,200', 'avatar': 'P', 'color': Colors.pink},
      {'name': 'Amit', 'role': 'Agent', 'hours': '4.1h', 'earnings': '₹5,100', 'avatar': 'A', 'color': Colors.green},
      {'name': 'Sneha', 'role': 'Host', 'hours': '3.9h', 'earnings': '₹4,800', 'avatar': 'S', 'color': Colors.orange},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Top Performers This Week', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: performers.length,
          itemBuilder: (context, index) {
            final p = performers[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: (p['color'] as Color).withValues(alpha: 0.2),
                    child: Text(
                      p['avatar'] as String,
                      style: TextStyle(color: p['color'] as Color, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                        Text(p['role'] as String, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(p['hours'] as String, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
                      const SizedBox(height: 2),
                      Text(p['earnings'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
