// ═══════════════════════════════════════════════════════════════════════════
// VIEW: StaffListView — Staff CRUD with role matrix and owner lock controls
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/role_permission_service.dart';

class StaffListView extends StatefulWidget {
  const StaffListView({super.key});

  @override
  State<StaffListView> createState() => _StaffListViewState();
}

class _StaffListViewState extends State<StaffListView> {
  final _permService = Get.find<RolePermissionService>();
  final _apiService = Get.find<ApiService>();

  List<Map<String, dynamic>> _staff = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/staff/list');
      if (response['success'] == true) {
        _staff = List<Map<String, dynamic>>.from(response['data'] ?? []);
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _toggleActive(String staffId, bool currentStatus) async {
    try {
      await _apiService.put('/staff/update/$staffId', {'isActive': !currentStatus});
      Get.snackbar('Success', currentStatus ? 'Staff deactivated' : 'Staff activated', backgroundColor: Colors.green);
      _loadStaff();
    } catch (_) {
      Get.snackbar('Error', 'Operation failed', backgroundColor: Colors.red);
    }
  }

  Future<void> _forceChangePassword(String staffId, String loginId) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Force Password: $loginId'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'New Password'),
          obscureText: true,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: null), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Get.back(result: controller.text), child: const Text('Change')),
        ],
      ),
    );
    if (result != null && result.length >= 6) {
      try {
        await _apiService.post('/staff/change-password/$staffId', {'newPassword': result});
        Get.snackbar('Success', 'Password changed and locked', backgroundColor: Colors.green);
      } catch (_) {
        Get.snackbar('Error', 'Password change failed', backgroundColor: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = _permService.hasPermission('staff.edit');
    final canChangePassword = _permService.hasPermission('staff.change_password');

    return Scaffold(
      appBar: AppBar(title: const Text('Staff Management')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _staff.isEmpty
              ? const Center(child: Text('No staff found'))
              : ListView.builder(
                  itemCount: _staff.length,
                  itemBuilder: (ctx, i) {
                    final s = _staff[i];
                    final roleColor = _getRoleColor(s['roleLevel'] ?? 0);
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: roleColor,
                          child: Text((s['name'] ?? s['loginId'] ?? 'S')[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(s['name'] ?? s['loginId'] ?? 'Unknown'),
                        subtitle: Text('${s['role'] ?? ''} | ${s['loginId'] ?? ''} | Level: ${s['roleLevel'] ?? 0}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: s['isActive'] == true ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(s['isActive'] == true ? 'Active' : 'Inactive', style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                            if (canEdit)
                              IconButton(
                                icon: Icon(s['isOwnerLocked'] == true ? Icons.lock : Icons.lock_open, color: Colors.orange),
                                onPressed: () => _forceChangePassword(s['_id'], s['loginId']),
                                tooltip: s['isOwnerLocked'] == true ? 'Locked by Owner' : 'Change Password',
                              ),
                            if (canEdit)
                              IconButton(
                                icon: Icon(s['isActive'] == true ? Icons.toggle_on : Icons.toggle_off, color: s['isActive'] == true ? Colors.green : Colors.grey),
                                onPressed: () => _toggleActive(s['_id'], s['isActive'] == true),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Color _getRoleColor(int level) {
    if (level >= 100) return Colors.purple;
    if (level >= 80) return Colors.red;
    if (level >= 60) return Colors.orange;
    if (level >= 40) return Colors.blue;
    if (level >= 20) return Colors.green;
    return Colors.grey;
  }
}