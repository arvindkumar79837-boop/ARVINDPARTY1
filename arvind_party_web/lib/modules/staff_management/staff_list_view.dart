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
  List<Map<String, dynamic>> _availableRoles = [];
  List<String> _allPermissions = [];
  Map<String, dynamic> _roleHierarchy = {};
  bool _isLoading = true;
  bool _isLoadingRoles = false;

  @override
  void initState() {
    super.initState();
    _loadStaff();
    _loadRoles();
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

  Future<void> _loadRoles() async {
    setState(() => _isLoadingRoles = true);
    try {
      final response = await _apiService.get('/roles');
      if (response['success'] == true) {
        _availableRoles = List<Map<String, dynamic>>.from(response['data']['roles'] ?? []);
        _allPermissions = List<String>.from(response['data']['allPermissions'] ?? []);
        _roleHierarchy = Map<String, dynamic>.from(response['data']['hierarchy'] ?? {});
      }
    } catch (_) {}
    setState(() => _isLoadingRoles = false);
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

    return Scaffold(
      appBar: AppBar(title: const Text('Staff Management'), actions: [
        if (canEdit)
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddStaffDialog(),
            tooltip: 'Add Staff',
          ),
      ]),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _staff.isEmpty
              ? const Center(child: Text('No staff found'))
              : ListView.builder(
                  itemCount: _staff.length,
                  itemBuilder: (ctx, i) {
                    final s = _staff[i];
                    final roleColor = _getRoleColor(s['roleLevel'] ?? 0);
                    final roleInfo = _roleHierarchy[s['role']] ?? {};
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: roleColor,
                          child: Text((s['name'] ?? s['loginId'] ?? 'S')[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(s['name'] ?? s['loginId'] ?? 'Unknown'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${roleInfo['label'] ?? s['role'] ?? ''} | ${s['loginId'] ?? ''} | Level: ${s['roleLevel'] ?? 0}'),
                            if (s['managedModule'] != null && s['managedModule'] != '')
                              Text('Module: ${s['managedModule']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
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
                                tooltip: 'Toggle Active',
                              ),
                          ],
                        ),
                        onTap: canEdit ? () => _showEditStaffDialog(s) : null,
                      ),
                    );
                  },
                ),
    );
  }

  void _showAddStaffDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    String? selectedRole;
    List<String> selectedPermissions = [];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Staff'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name')),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Role'),
                items: _availableRoles.map((role) {
                  return DropdownMenuItem<String>(
                    value: role['role'],
                    child: Text('${role['label']} ${role['labelHi'] ?? ''}'),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedRole = value;
                  final role = _availableRoles.firstWhereOrNull((r) => r['role'] == value);
                  if (role != null && role['defaultPermissions'] != null) {
                    selectedPermissions = List<String>.from(role['defaultPermissions']);
                  }
                },
              ),
              const SizedBox(height: 12),
              const Text('Permissions:', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: _allPermissions.take(20).map((perm) {
                  final isSelected = selectedPermissions.contains(perm);
                  return FilterChip(
                    label: Text(perm, style: const TextStyle(fontSize: 11)),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        selectedPermissions.add(perm);
                      } else {
                        selectedPermissions.remove(perm);
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || emailController.text.isEmpty || selectedRole == null) {
                Get.snackbar('Error', 'Please fill all required fields', backgroundColor: Colors.red);
                return;
              }
              try {
                final response = await _apiService.post('/staff/create', {
                  'loginId': emailController.text.split('@')[0],
                  'password': 'TempPass123!',
                  'name': nameController.text,
                  'email': emailController.text,
                  'phone': phoneController.text,
                  'role': selectedRole,
                  'permissions': selectedPermissions,
                });
                if (response['success'] == true) {
                  Get.snackbar('Success', 'Staff created', backgroundColor: Colors.green);
                  Get.back();
                  _loadStaff();
                } else {
                  Get.snackbar('Error', response['message'] ?? 'Failed', backgroundColor: Colors.red);
                }
              } catch (_) {
                Get.snackbar('Error', 'Failed to create staff', backgroundColor: Colors.red);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditStaffDialog(Map<String, dynamic> staff) {
    final nameController = TextEditingController(text: staff['name'] ?? '');
    final emailController = TextEditingController(text: staff['email'] ?? '');
    final phoneController = TextEditingController(text: staff['phone'] ?? '');
    String? selectedRole = staff['role'];
    List<String> selectedPermissions = List<String>.from(staff['permissions'] ?? []);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit: ${staff['name']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name')),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Role'),
                initialValue: selectedRole,
                items: _availableRoles.map((role) {
                  return DropdownMenuItem<String>(
                    value: role['role'],
                    child: Text('${role['label']} ${role['labelHi'] ?? ''}'),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedRole = value;
                  final role = _availableRoles.firstWhereOrNull((r) => r['role'] == value);
                  if (role != null && role['defaultPermissions'] != null) {
                    selectedPermissions = List<String>.from(role['defaultPermissions']);
                  }
                },
              ),
              const SizedBox(height: 12),
              const Text('Permissions:', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: _allPermissions.take(20).map((perm) {
                  final isSelected = selectedPermissions.contains(perm);
                  return FilterChip(
                    label: Text(perm, style: const TextStyle(fontSize: 11)),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        selectedPermissions.add(perm);
                      } else {
                        selectedPermissions.remove(perm);
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                final response = await _apiService.put('/staff/update/${staff['_id']}', {
                  'name': nameController.text,
                  'email': emailController.text,
                  'phone': phoneController.text,
                  'role': selectedRole,
                  'permissions': selectedPermissions,
                });
                if (response['success'] == true) {
                  Get.snackbar('Success', 'Staff updated', backgroundColor: Colors.green);
                  Get.back();
                  _loadStaff();
                } else {
                  Get.snackbar('Error', response['message'] ?? 'Failed', backgroundColor: Colors.red);
                }
              } catch (_) {
                Get.snackbar('Error', 'Failed to update staff', backgroundColor: Colors.red);
              }
            },
            child: const Text('Update'),
          ),
        ],
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