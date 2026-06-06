// ═══════════════════════════════════════════════════════════════════════════
// FILE: arvind_party_web/lib/modules/owner/views/staff_management_view.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'api_constants.dart';
import '../../../core/constants/role_constants.dart';

class StaffManagementView extends StatefulWidget {
  const StaffManagementView({super.key});

  @override
  State<StaffManagementView> createState() => _StaffManagementViewState();
}

class _StaffManagementViewState extends State<StaffManagementView> {
  final TextEditingController _uidController = TextEditingController();
  final TextEditingController _loginIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _userFound = false;
  String _selectedRole = AppRoles.adminUid;

  // Permissions State
  final Map<String, bool> _permissions = {
    AppPermissions.viewUsers: false,
    AppPermissions.editUsers: false,
    AppPermissions.banUsers: false,
    AppPermissions.viewRooms: false,
    AppPermissions.editRooms: false,
    AppPermissions.closeRooms: false,
    AppPermissions.viewWallet: false,
    AppPermissions.rechargeWallet: false,
    AppPermissions.manageEvents: false,
    AppPermissions.manageReports: false,
  };

  void _searchUser() {
    // TODO: Connect to backend API to search user by UID
    if (_uidController.text.isNotEmpty) {
      setState(() {
        _userFound = true;
        // Auto-generate Login ID based on UID
        _loginIdController.text = "staff_${_uidController.text}";
      });
    }
  }

  void _generatePassword() {
    // Temporary logic: Generate a random 8 char password
    setState(() {
      _passwordController.text =
          "Arvind@${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
    });
  }

  Future<void> _assignRoleAndPermissions() async {
    final selectedPerms = _permissions.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    try {
      final token = GetStorage().read('staff_token');
      final response = await http.post(
        Uri.parse('${ApiConstants.apiBaseUrl}/staff/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'uid': _uidController.text.trim(),
          'loginId': _loginIdController.text.trim(),
          'password': _passwordController.text.trim(),
          'role': _selectedRole,
          'permissions': selectedPerms,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] ?? 'Failed to create staff');
      }

      Get.snackbar(
        'Success',
        'Role $_selectedRole assigned to UID: ${_uidController.text}\nPermissions: ${selectedPerms.length}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Staff & Role Management (Owner Only)',
          style: TextStyle(color: Color(0xFFFF8906)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── SEARCH UID SECTION ───
            const Text(
              'Assign Role via UID',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _uidController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Enter User UID',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_search),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _searchUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8906),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                  ),
                  child: const Text(
                    'Search User',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(flex: 3),
              ],
            ),

            const SizedBox(height: 32),

            // ─── USER FOUND & PERMISSION BUILDER ───
            if (_userFound) ...[
              const Divider(color: Colors.white24),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LEFT COLUMN: Credentials & Role
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Staff Credentials',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _loginIdController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Login ID (Auto Generated)',
                              border: OutlineInputBorder(),
                            ),
                            readOnly:
                                true, // Only owner generates this, cannot be changed manually easily
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _passwordController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    labelText: 'Password',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.autorenew,
                                  color: Color(0xFFFF8906),
                                ),
                                onPressed: _generatePassword,
                                tooltip: 'Auto Generate',
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Select Role',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedRole,
                            dropdownColor: const Color(0xFF15141F),
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            items: AppRoles.allRoles
                                .where((r) => r != AppRoles.ownerWeb)
                                .map((String role) {
                                  return DropdownMenuItem<String>(
                                    value: role,
                                    child: Text(role),
                                  );
                                })
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedRole = val);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),

                  // RIGHT COLUMN: Permission Checkboxes
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Permission Builder',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: _permissions.keys.map((String key) {
                              return SizedBox(
                                width: 200,
                                child: CheckboxListTile(
                                  title: Text(
                                    key.replaceAll('_', ' '),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  value: _permissions[key],
                                  activeColor: const Color(0xFFFF8906),
                                  checkColor: Colors.black,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _permissions[key] = value ?? false;
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _assignRoleAndPermissions,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: const Text(
                                'Save & Assign Role',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
