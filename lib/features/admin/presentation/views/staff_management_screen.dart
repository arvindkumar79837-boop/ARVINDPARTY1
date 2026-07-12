// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/admin/presentation/views/staff_management_screen.dart
// ARVIND PARTY - STAFF MANAGEMENT PANEL
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';

class StaffManagementScreen extends StatelessWidget {
  const StaffManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Staff Management',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildAddStaffForm(controller),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: Colors.orange),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => controller.loadStaff(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.staffMembers.length,
                    itemBuilder: (ctx, index) {
                      final staff = controller.staffMembers[index];
                      return _buildStaffCard(ctx, staff, controller);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddStaffForm(AdminController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withValues(alpha: 0.15),
            Colors.deepPurple.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add New Staff',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (value) => controller.staffName.value = value,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Full Name',
              labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              errorText: _getNameError(controller.staffName.value),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (value) => controller.staffEmail.value = value,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Address',
              labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              errorText: _getEmailError(controller.staffEmail.value),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => DropdownButtonFormField<String>(
            initialValue: controller.staffRole.value.isEmpty ? null : controller.staffRole.value,
            style: const TextStyle(color: Colors.white),
            dropdownColor: const Color(0xFF2A2A3E),
            decoration: InputDecoration(
              labelText: 'Role',
              labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              errorText: _getRoleError(controller.staffRole.value),
            ),
            items: const [
              DropdownMenuItem(value: 'moderator', child: Text('Moderator')),
              DropdownMenuItem(value: 'support', child: Text('Support')),
              DropdownMenuItem(value: 'analyst', child: Text('Analyst')),
              DropdownMenuItem(value: 'manager', child: Text('Manager')),
            ],
            onChanged: (value) {
              if (value != null) controller.staffRole.value = value;
            },
          )),
          const SizedBox(height: 12),
          Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Permissions',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildPermissionChip('users.view', controller),
                  _buildPermissionChip('users.block', controller),
                  _buildPermissionChip('broadcasts.create', controller),
                  _buildPermissionChip('wallet.adjust', controller),
                  _buildPermissionChip('reports.view', controller),
                  _buildPermissionChip('settings.edit', controller),
                ],
              ),
            ],
          )),
          const SizedBox(height: 16),
          Obx(() {
            final isEditing = controller.selectedStaffId.value != null;
            return Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (isEditing) {
                        controller.updateStaff(controller.selectedStaffId.value!);
                        controller.selectedStaffId.value = null;
                      } else {
                        controller.addStaff();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      isEditing ? 'Update Staff' : 'Add Staff',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                if (isEditing) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      controller.selectedStaffId.value = null;
                      controller.staffName.value = '';
                      controller.staffEmail.value = '';
                      controller.staffRole.value = '';
                      controller.staffPermissions.clear();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPermissionChip(String permission, AdminController controller) {
    final isSelected = controller.staffPermissions.contains(permission);
    return GestureDetector(
      onTap: () => controller.togglePermission(permission),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.purple.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          permission,
          style: TextStyle(
            fontSize: 11,
            color: isSelected ? Colors.purple : Colors.white70,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStaffCard(BuildContext context, Map<String, dynamic> staff, AdminController controller) {
    final role = staff['role'] as String;
    Color roleColor;
    switch (role) {
      case 'moderator':
        roleColor = Colors.purple;
        break;
      case 'support':
        roleColor = Colors.blue;
        break;
      case 'analyst':
        roleColor = Colors.cyan;
        break;
      case 'manager':
        roleColor = Colors.orange;
        break;
      default:
        roleColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [roleColor, roleColor.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    staff['name'][0],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staff['name'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      staff['email'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  role.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    color: roleColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: (staff['permissions'] as List<String>)
                .map((p) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        p,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.purple.withValues(alpha: 0.8),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => controller.selectStaffForEdit(staff['id']),
                  icon: const Icon(Icons.edit, size: 14, color: Colors.blue),
                  label: const Text('Edit', style: TextStyle(fontSize: 12, color: Colors.blue)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _confirmDelete(context, controller, staff['id'], staff['name']),
                  icon: const Icon(Icons.delete, size: 14, color: Colors.red),
                  label: const Text('Delete', style: TextStyle(fontSize: 12, color: Colors.red)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red.withValues(alpha: 0.1),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminController controller, String id, String name) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text('Confirm Delete', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to remove $name?',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteStaff(id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String? _getNameError(String value) {
    if (value.isEmpty) return null;
    if (value.length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? _getEmailError(String value) {
    if (value.isEmpty) return null;
    if (!GetUtils.isEmail(value)) return 'Invalid email';
    return null;
  }

  String? _getRoleError(String value) {
    if (value.isEmpty) return null;
    return null;
  }
}