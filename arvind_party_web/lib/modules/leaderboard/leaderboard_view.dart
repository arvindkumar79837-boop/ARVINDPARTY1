// ═══════════════════════════════════════════════════════════════════════════
// VIEW: LeaderboardView — Leaderboard management
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/role_permission_service.dart';

class LeaderboardView extends StatefulWidget {
  const LeaderboardView({super.key});

  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  final _permService = Get.find<RolePermissionService>();
  final _apiService = Get.find<ApiService>();

  List<Map<String, dynamic>> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/leaderboard');
      if (response['success'] == true) {
        _entries = List<Map<String, dynamic>>.from(response['data'] ?? []);
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _resetLeaderboard() async {
    try {
      await _apiService.post('/leaderboard/reset', {});
      Get.snackbar('Success', 'Leaderboard reset', backgroundColor: Colors.green);
      _loadLeaderboard();
    } catch (_) {
      Get.snackbar('Error', 'Reset failed', backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canReset = _permService.hasPermission('leaderboard.reset');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        actions: [
          if (canReset)
            IconButton(onPressed: _resetLeaderboard, icon: const Icon(Icons.refresh), tooltip: 'Reset Leaderboard'),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? const Center(child: Text('No leaderboard entries'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _entries.length,
                  itemBuilder: (ctx, i) {
                    final entry = _entries[i];
                    final rank = i + 1;
                    Color rankColor = Colors.grey;
                    if (rank == 1) rankColor = Colors.amber;
                    else if (rank == 2) rankColor = Colors.blueGrey;
                    else if (rank == 3) rankColor = Colors.brown;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: rankColor,
                          child: Text('$rank', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(entry['username'] ?? 'Unknown'),
                        subtitle: Text('Score: ${entry['score'] ?? 0} | Level: ${entry['level'] ?? 0}'),
                      ),
                    );
                  },
                ),
    );
  }
}