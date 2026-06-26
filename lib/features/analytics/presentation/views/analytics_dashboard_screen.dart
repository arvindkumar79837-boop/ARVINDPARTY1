import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/analytics_controller.dart';

class AnalyticsDashboardScreen extends GetView<AnalyticsController> {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('📊 Live Analytics Dashboard'),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => controller.refreshAll(),
              tooltip: 'Refresh All Data',
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.account_balance), text: 'Revenue'),
              Tab(icon: Icon(Icons.people), text: 'Engagement'),
              Tab(icon: Icon(Icons.business), text: 'Departments'),
              Tab(icon: Icon(Icons.map), text: 'Charts'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _RevenueTab(),
            _EngagementTab(),
            _DepartmentalTab(),
            _ChartsTab(),
          ],
        ),
      ),
    );
  }
}

class _RevenueTab extends GetView<AnalyticsController> {
  const _RevenueTab();

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final numberFormat = NumberFormat.decimalPattern('en_IN');

    return Obx(() {
      if (controller.isLoadingRevenue.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final summary = controller.revenueSummary.value;
      if (summary == null) {
        return const Center(child: Text('No revenue data available'));
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('💰 Total Revenue'),
            const SizedBox(height: 8),
            _buildMetricCard(
              'Total Revenue',
              currencyFormat.format(summary['totalRevenue'] ?? 0),
              Icons.bar_chart,
              Colors.green,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildMetricCard('Today', currencyFormat.format(summary['todayRevenue'] ?? 0), Icons.today, Colors.blue)),
                const SizedBox(width: 8),
                Expanded(child: _buildMetricCard('This Week', currencyFormat.format(summary['thisWeekRevenue'] ?? 0), Icons.calendar_view_week, Colors.orange)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildMetricCard('This Month', currencyFormat.format(summary['thisMonthRevenue'] ?? 0), Icons.calendar_month, Colors.purple)),
                const SizedBox(width: 8),
                Expanded(child: _buildMetricCard('Diamonds Today', numberFormat.format(summary['todayDiamondsEarned'] ?? 0), Icons.diamond, Colors.amber)),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('💸 Payouts & Commission'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildMetricCard('Total Payouts', currencyFormat.format(summary['totalPayouts'] ?? 0), Icons.account_balance_wallet, Colors.redAccent)),
                const SizedBox(width: 8),
                Expanded(child: _buildMetricCard('Pending Withdrawals', currencyFormat.format(summary['pendingWithdrawalsAmount'] ?? 0), Icons.hourglass_top, Colors.amber[700]!)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildMetricCard('Commission Paid', currencyFormat.format(summary['totalCommissionPaid'] ?? 0), Icons.monetization_on, Colors.teal)),
                const SizedBox(width: 8),
                Expanded(child: _buildMetricCard('Coin Seller Sales', currencyFormat.format(summary['coinSellerTotalSales'] ?? 0), Icons.store, Colors.indigo)),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}

class _EngagementTab extends GetView<AnalyticsController> {
  const _EngagementTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingEngagement.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final userData = controller.userAnalytics.value;
      final liveData = controller.liveAnalytics.value;
      final giftData = controller.giftAnalytics.value;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('👥 User Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (userData != null) ...[
              Row(children: [
                Expanded(child: _buildStatCard('DAU', '${userData['dau'] ?? 0}', Colors.blue)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard('WAU', '${userData['wau'] ?? 0}', Colors.green)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _buildStatCard('MAU', '${userData['mau'] ?? 0}', Colors.purple)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard('New Today', '${userData['newRegistrationsToday'] ?? 0}', Colors.orange)),
              ]),
              const SizedBox(height: 8),
              _buildStatCard('Avg Time Spent', '${userData['avgTimeSpentMinutes'] ?? 0} min', Colors.cyan, fullWidth: true),
            ],
            const SizedBox(height: 16),
            const Text('🎙️ Live Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (liveData != null) ...[
              Row(children: [
                Expanded(child: _buildStatCard('Active Rooms', '${liveData['activeVoiceRooms'] ?? 0}', Colors.redAccent)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard('Online Users', '${liveData['onlineUsers'] ?? 0}', Colors.teal)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _buildStatCard('Seats Filled', '${liveData['filledSeats'] ?? 0}', Colors.amber)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard('Total Seats', '${liveData['totalSeats'] ?? 0}', Colors.indigo)),
              ]),
            ],
            const SizedBox(height: 16),
            const Text('🎁 Gift Analytics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (giftData != null) ...[
              if (giftData['topGifts'] != null)
                ...List.generate(
                  (giftData['topGifts'] as List).take(5).length,
                  (i) {
                    final gift = (giftData['topGifts'] as List)[i] as Map<String, dynamic>;
                    return ListTile(
                      leading: CircleAvatar(child: Text('${i + 1}')),
                      title: Text(gift['giftName'] ?? 'Gift'),
                      subtitle: Text('Sent: ${gift['totalSentCount'] ?? 0} times'),
                      trailing: Text('💎 ${gift['totalDiamondValue'] ?? 0}'),
                    );
                  },
                ),
              const Divider(),
              if (giftData['topRooms'] != null)
                Text('🔥 Top Rooms: ${(giftData['topRooms'] as List).length} rooms with highest gift values'),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildStatCard(String label, String value, Color color, {bool fullWidth = false}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}

class _DepartmentalTab extends GetView<AnalyticsController> {
  const _DepartmentalTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingDepartmental.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🏢 Agency Rankings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (controller.agencyRankings.isEmpty)
              const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No agency data yet')))
            else
              ...controller.agencyRankings.take(10).map((agency) {
                final trendIcon = agency['trend'] == 'up' ? Icons.trending_up : (agency['trend'] == 'down' ? Icons.trending_down : Icons.trending_flat);
                final trendColor = agency['trend'] == 'up' ? Colors.green : (agency['trend'] == 'down' ? Colors.red : Colors.grey);
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${agency['rankingPosition'] ?? '?'}')),
                    title: Text(agency['agencyName'] ?? 'Unknown'),
                    subtitle: Text('Hosts: ${agency['totalHosts'] ?? 0} | Diamonds: 💎 ${agency['totalDiamondsEarned'] ?? 0}'),
                    trailing: Icon(trendIcon, color: trendColor),
                  ),
                );
              }),
            const SizedBox(height: 16),
            const Text('👪 Family Rankings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (controller.familyRankings.isEmpty)
              const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No family data yet')))
            else
              ...controller.familyRankings.take(10).map((family) {
                final trendIcon = family['trend'] == 'up' ? Icons.trending_up : (family['trend'] == 'down' ? Icons.trending_down : Icons.trending_flat);
                final trendColor = family['trend'] == 'up' ? Colors.green : (family['trend'] == 'down' ? Colors.red : Colors.grey);
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${family['rankingPosition'] ?? '?'}')),
                    title: Text(family['familyName'] ?? 'Unknown'),
                    subtitle: Text('Members: ${family['totalMembers'] ?? 0} | Points: ${family['rankingPoints'] ?? 0}'),
                    trailing: Icon(trendIcon, color: trendColor),
                  ),
                );
              }),
          ],
        ),
      );
    });
  }
}

class _ChartsTab extends GetView<AnalyticsController> {
  const _ChartsTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingCharts.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📈 Hourly Revenue & Diamonds', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (controller.chartData.value != null) ...[
              _buildSimpleChart(controller.chartData.value!),
            ],
            const SizedBox(height: 16),
            const Text('🌍 Activity Heat Map', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (controller.heatMapData.isEmpty)
              const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No heat map data yet')))
            else
              ...controller.heatMapData.take(10).map((entry) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.red),
                    title: Text('${entry['country'] ?? 'Unknown'}${entry['state'] != null && entry['state']!.isNotEmpty ? ', ${entry['state']}' : ''}'),
                    subtitle: Text('Active Users: ${entry['activeUsers'] ?? 0} | Time: ${entry['totalTimeSpentMinutes'] ?? 0} min'),
                    trailing: Text('💎 ${entry['diamondsEarned'] ?? 0}'),
                  ),
                );
              }),
          ],
        ),
      );
    });
  }

  Widget _buildSimpleChart(Map<String, dynamic> chartData) {
    final hourly = chartData['hourly'] as List<dynamic>? ?? [];
    final now = DateTime.now();
    final currentHour = now.hour;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Today\'s Activity (last updated: ${now.hour}:${now.minute.toString().padLeft(2, '0')})'),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: hourly.length,
                itemBuilder: (context, index) {
                  final entry = hourly[index] as Map<String, dynamic>;
                  final hour = entry['hour'] as int? ?? 0;
                  final revenue = (entry['revenue'] as num?)?.toDouble() ?? 0;
                  final diamonds = (entry['diamonds'] as num?)?.toDouble() ?? 0;
                  final isCurrent = hour == currentHour;

                  return Container(
                    width: 40,
                    margin: const EdgeInsets.only(right: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('${diamonds ~/ 1000}k', style: TextStyle(fontSize: 8, color: Colors.amber.shade700)),
                        Container(
                          height: (revenue > 0) ? ((revenue / 100000) * 60).clamp(4, 60).toDouble() : 4,
                          width: 16,
                          decoration: BoxDecoration(
                            color: isCurrent ? Colors.orange : Colors.blue.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text('$hour:00', style: TextStyle(fontSize: 8, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}