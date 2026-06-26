// ═══════════════════════════════════════════════════════════════════════════
// VIEW: DashboardView — Live stats and activity overview
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final _apiService = Get.find<ApiService>();
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _activity = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/admin/stats');
      if (response['success'] == true) {
        _stats = Map<String, dynamic>.from(response['data'] ?? {});
      }
      final activityResp = await _apiService.get('/admin/dashboard/activity');
      if (activityResp['success'] == true) {
        _activity = List<Map<String, dynamic>>.from(activityResp['data'] ?? []);
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── STATS CARDS ────────────────────────────────
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Total Users', '${_stats['totalUsers'] ?? 0}', Colors.blue)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildStatCard('Live Rooms', '${_stats['liveRooms'] ?? 0}', Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Revenue', '${_stats['totalRevenue'] ?? 0}', Colors.green)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildStatCard('Active Today', '${_stats['activeToday'] ?? 0}', Colors.orange)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ─── ACTIVITY FEED ──────────────────────────────
                  const Text('Live Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _activity.isEmpty
                      ? const Text('No recent activity')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _activity.length,
                          itemBuilder: (ctx, i) {
                            final item = _activity[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Icon(Icons.trending_up, color: Colors.blue),
                                title: Text(item['type'] ?? 'Activity'),
                                subtitle: Text(item['description'] ?? ''),
                                trailing: Text(item['timestamp'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}