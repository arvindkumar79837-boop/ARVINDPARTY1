// ═══════════════════════════════════════════════════════════════════════════
// VIEW: UserManagementView — Full user CRUD for admin panel
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/role_permission_service.dart';

class UserManagementView extends StatefulWidget {
  const UserManagementView({super.key});

  @override
  State<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView> {
  final _permService = Get.find<RolePermissionService>();
  final _apiService = Get.find<ApiService>();

  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filter = 'all'; // all, verified, banned, active

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final queryParams = <String, String>{};
      if (_filter == 'verified') queryParams['isVerified'] = 'true';
      if (_filter == 'banned') queryParams['isBanned'] = 'true';
      if (_searchQuery.isNotEmpty) queryParams['search'] = _searchQuery;

      final response = await _apiService.get('/users', queryParams: queryParams);
      if (response['success'] == true) {
        _users = List<Map<String, dynamic>>.from(response['data'] ?? []);
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _toggleBan(String userId, bool currentStatus) async {
    try {
      await _apiService.post('/users/block/$userId', {});
      Get.snackbar('Success', currentStatus ? 'User unbanned' : 'User banned', backgroundColor: Colors.green);
      _loadUsers();
    } catch (_) {
      Get.snackbar('Error', 'Operation failed', backgroundColor: Colors.red);
    }
  }

  Future<void> _verifyUser(String userId) async {
    try {
      await _apiService.put('/users/verify/$userId', {});
      Get.snackbar('Success', 'User verified', backgroundColor: Colors.green);
      _loadUsers();
    } catch (_) {
      Get.snackbar('Error', 'Verification failed', backgroundColor: Colors.red);
    }
  }

  Future<void> _adjustCoins(String userId) async {
    final controller = TextEditingController();
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adjust Coins'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Amount (negative to deduct)'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: null), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Get.back(result: int.tryParse(controller.text)), child: const Text('Adjust')),
        ],
      ),
    );
    if (result != null && result != 0) {
      try {
        await _apiService.post('/users/adjust-coins/$userId', {'amount': result, 'reason': 'Admin adjustment'});
        Get.snackbar('Success', 'Coins adjusted by $result', backgroundColor: Colors.green);
        _loadUsers();
      } catch (_) {
        Get.snackbar('Error', 'Adjustment failed', backgroundColor: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canBan = _permService.hasPermission('users.ban');
    final canVerify = _permService.hasPermission('users.verify');
    final canAdjust = _permService.hasPermission('users.adjust_coins');

    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: Column(
        children: [
          // ─── FILTERS ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Search users...', border: OutlineInputBorder()),
                    onChanged: (v) { setState(() => _searchQuery = v); _loadUsers(); },
                  ),
                ),
                const SizedBox(width: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'all', label: Text('All')),
                    ButtonSegment(value: 'verified', label: Text('Verified')),
                    ButtonSegment(value: 'banned', label: Text('Banned')),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (v) { setState(() => _filter = v.first); _loadUsers(); },
                ),
              ],
            ),
          ),

          // ─── USER LIST ────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                    ? const Center(child: Text('No users found'))
                    : ListView.builder(
                        itemCount: _users.length,
                        itemBuilder: (ctx, i) {
                          final user = _users[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(child: Text((user['name'] ?? 'U')[0].toUpperCase())),
                              title: Text(user['name'] ?? 'Unknown'),
                              subtitle: Text('UID: ${user['uid']} | Coins: ${user['coins'] ?? 0} | Diamonds: ${user['diamonds'] ?? 0}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (canVerify && user['isVerified'] != true)
                                    IconButton(icon: const Icon(Icons.verified, color: Colors.blue), onPressed: () => _verifyUser(user['_id'])),
                                  if (canAdjust)
                                    IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _adjustCoins(user['_id'])),
                                  if (canBan)
                                    IconButton(
                                      icon: Icon(user['isBanned'] == true ? Icons.lock_open : Icons.lock, color: user['isBanned'] == true ? Colors.green : Colors.red),
                                      onPressed: () => _toggleBan(user['_id'], user['isBanned'] == true),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}