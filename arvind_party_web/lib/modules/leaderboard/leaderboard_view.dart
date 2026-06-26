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
  String _selectedType = 'wealth';
  String _selectedPeriod = 'daily';
  String _selectedCountry = 'global';

  final List<Map<String, String>> _rankingTypes = [
    {'value': 'wealth', 'label': 'Wealth Ranking'},
    {'value': 'charm', 'label': 'Charm Ranking'},
    {'value': 'gift', 'label': 'Gift Ranking'},
    {'value': 'families', 'label': 'Family Ranking'},
    {'value': 'agencies', 'label': 'Agency Ranking'},
    {'value': 'rooms', 'label': 'Room Ranking'},
    {'value': 'pk-battles', 'label': 'PK Battle Ranking'},
    {'value': 'rich-list', 'label': 'Rich List'},
    {'value': 'popular-list', 'label': 'Popular List'},
  ];

  final List<Map<String, String>> _periods = [
    {'value': 'daily', 'label': 'Daily'},
    {'value': 'weekly', 'label': 'Weekly'},
    {'value': 'monthly', 'label': 'Monthly'},
    {'value': 'yearly', 'label': 'Yearly'},
  ];

  final List<Map<String, String>> _countries = [
    {'value': 'global', 'label': 'Global'},
    {'value': 'India', 'label': 'India'},
    {'value': 'UAE', 'label': 'UAE'},
    {'value': 'Saudi Arabia', 'label': 'Saudi Arabia'},
  ];

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get(
        '/rankings/$_selectedType',
        queryParams: {
          'period': _selectedPeriod,
          'country': _selectedCountry,
          'limit': '100',
        },
      );

      if (response['success'] == true) {
        final rankings = response['rankings'] ?? response['data'] ?? [];
        setState(() {
          _entries = List<Map<String, dynamic>>.from(rankings);
        });
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to load leaderboard', backgroundColor: Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resetLeaderboard() async {
    try {
      await _apiService.post('/rankings/admin/reset', {});
      Get.snackbar('Success', 'Leaderboard reset successfully', backgroundColor: Colors.green);
      _loadLeaderboard();
    } catch (_) {
      Get.snackbar('Error', 'Reset failed', backgroundColor: Colors.red);
    }
  }

  Future<void> _flushCache() async {
    try {
      await _apiService.post('/rankings/admin/flush-cache', {
        'period': _selectedPeriod,
      });
      Get.snackbar('Success', 'Cache flushed successfully', backgroundColor: Colors.green);
      _loadLeaderboard();
    } catch (_) {
      Get.snackbar('Error', 'Flush failed', backgroundColor: Colors.red);
    }
  }

  Future<void> _initializeRankings() async {
    try {
      await _apiService.post('/rankings/admin/initialize', {});
      Get.snackbar('Success', 'Rankings initialized from MongoDB', backgroundColor: Colors.green);
      _loadLeaderboard();
    } catch (_) {
      Get.snackbar('Error', 'Initialization failed', backgroundColor: Colors.red);
    }
  }

  String _getDisplayName(Map<String, dynamic> entry) {
    return entry['userName'] ??
        entry['name'] ??
        entry['username'] ??
        entry['familyName'] ??
        entry['agencyName'] ??
        entry['roomName'] ??
        'Unknown';
  }

  dynamic _getScore(Map<String, dynamic> entry) {
    switch (_selectedType) {
      case 'charm':
      case 'popular-list':
        return entry['coins'] ?? entry['score'] ?? 0;
      case 'gift':
        return entry['score'] ?? 0;
      case 'wealth':
      case 'rich-list':
      default:
        return entry['diamonds'] ?? entry['score'] ?? 0;
    }
  }

  String? _getSubtitle(Map<String, dynamic> entry) {
    switch (_selectedType) {
      case 'families':
        return 'Members: ${entry['memberCount'] ?? 'N/A'} | Points: ${entry['score'] ?? 0}';
      case 'agencies':
        return 'Hosts: ${entry['totalHosts'] ?? 'N/A'} | Diamonds: ${entry['score'] ?? 0}';
      case 'rooms':
        return 'Viewers: ${entry['activeUsers'] ?? 'N/A'} | Traffic: ${entry['score'] ?? 0}';
      case 'pk-battles':
        final wins = entry['wins'] ?? 0;
        return 'Wins: $wins | Score: ${entry['score'] ?? 0}';
      default:
        final country = entry['country'];
        return country != null && country != 'global' ? 'Country: $country' : null;
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return const Color(0xFF2D2D44);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canReset = _permService.hasPermission('leaderboard.reset');
    final canFlush = _permService.hasPermission('leaderboard.flush');
    final canInitialize = _permService.hasPermission('leaderboard.initialize');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard Management'),
        actions: [
          if (canInitialize)
            IconButton(
              onPressed: _initializeRankings,
              icon: const Icon(Icons.sync),
              tooltip: 'Initialize from MongoDB',
            ),
          if (canFlush)
            IconButton(
              onPressed: _flushCache,
              icon: const Icon(Icons.cleaning_services),
              tooltip: 'Flush Cache',
            ),
          if (canReset)
            IconButton(
              onPressed: _resetLeaderboard,
              icon: const Icon(Icons.refresh),
              tooltip: 'Reset Leaderboard',
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Ranking Type',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _rankingTypes
                            .map((type) => DropdownMenuItem(
                                  value: type['value'],
                                  child: Text(type['label']!),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedType = value);
                            _loadLeaderboard();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedPeriod,
                        decoration: const InputDecoration(
                          labelText: 'Period',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _periods
                            .map((period) => DropdownMenuItem(
                                  value: period['value'],
                                  child: Text(period['label']!),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedPeriod = value);
                            _loadLeaderboard();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCountry,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _countries
                      .map((country) => DropdownMenuItem(
                            value: country['value'],
                            child: Text(country['label']!),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCountry = value);
                      _loadLeaderboard();
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _entries.isEmpty
                    ? const Center(child: Text('No leaderboard entries'))
                    : RefreshIndicator(
                        onRefresh: _loadLeaderboard,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _entries.length,
                          itemBuilder: (ctx, i) {
                            final entry = _entries[i];
                            final rank = i + 1;
                            final displayName = _getDisplayName(entry);
                            final score = _getScore(entry);
                            final subtitle = _getSubtitle(entry);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              color: rank <= 3 ? const Color(0xFF2D2D44).withOpacity(0.9) : null,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getRankColor(rank),
                                  child: Text(
                                    '$rank',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: subtitle != null
                                    ? Text(
                                        subtitle,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      )
                                    : null,
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFFD4AF37), Color(0xFFF4E285)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                  ),
                                  child: Text(
                                    '$score',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}