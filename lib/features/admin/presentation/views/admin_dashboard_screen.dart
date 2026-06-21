// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/admin/presentation/views/admin_dashboard_screen.dart
// ARVIND PARTY - ADMIN DASHBOARD OVERVIEW
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.find<AdminController>();

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
          'Admin Dashboard',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildStatsCards(controller),
            const SizedBox(height: 16),
            _buildFilters(controller),
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
                  onRefresh: () => controller.loadUsers(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.filteredUsers.length,
                    itemBuilder: (ctx, index) {
                      final user = controller.filteredUsers[index];
                      return _buildUserCard(ctx, user, controller);
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

  Widget _buildStatsCards(AdminController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Total Users', '0', Colors.blue)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('Active', '0', Colors.green)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('Blocked', '0', Colors.orange)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('Banned', '0', Colors.red)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(AdminController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => controller.searchQuery.value = value,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search users...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.5)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.orange),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Obx(() => DropdownButton<String>(
            value: controller.statusFilter.value,
            style: const TextStyle(color: Colors.white),
            dropdownColor: const Color(0xFF2A2A3E),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All')),
              DropdownMenuItem(value: 'active', child: Text('Active')),
              DropdownMenuItem(value: 'blocked', child: Text('Blocked')),
              DropdownMenuItem(value: 'banned', child: Text('Banned')),
            ],
            onChanged: (value) {
              if (value != null) controller.statusFilter.value = value;
            },
          )),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, Map<String, dynamic> user, AdminController controller) {
    final status = user['status'] as String;
    Color statusColor;
    switch (status) {
      case 'active':
        statusColor = Colors.green;
        break;
      case 'blocked':
        statusColor = Colors.orange;
        break;
      case 'banned':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
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
                  gradient: const LinearGradient(
                    colors: [Colors.purple, Colors.blue],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    (user['name'] as String)[0],
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
                      user['name'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user['email'],
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
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on_outlined, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      '${user['coins']}',
                      style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.diamond_outlined, size: 14, color: Colors.cyan),
                    const SizedBox(width: 4),
                    Text(
                      '${user['diamonds']}',
                      style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
              Text(
                'ID: ${user['id']}',
                style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: status != 'blocked'
                      ? () => controller.blockUser(user['id'])
                      : null,
                  icon: const Icon(Icons.block, size: 14, color: Colors.orange),
                  label: const Text('Block', style: TextStyle(fontSize: 12, color: Colors.orange)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.orange.withValues(alpha: 0.1),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton.icon(
                  onPressed: status != 'banned'
                      ? () => controller.banUser(user['id'])
                      : null,
                  icon: const Icon(Icons.gavel, size: 14, color: Colors.red),
                  label: const Text('Ban', style: TextStyle(fontSize: 12, color: Colors.red)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red.withValues(alpha: 0.1),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton.icon(
                  onPressed: status != 'active'
                      ? () => controller.unblockUser(user['id'])
                      : null,
                  icon: const Icon(Icons.check_circle, size: 14, color: Colors.green),
                  label: const Text('Restore', style: TextStyle(fontSize: 12, color: Colors.green)),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green.withValues(alpha: 0.1),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildWalletAdjustButton(context, user, controller),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalletAdjustButton(BuildContext context, Map<String, dynamic> user, AdminController controller) {
    return TextButton.icon(
      onPressed: () => _showWalletAdjustDialog(context, user, controller),
      icon: const Icon(Icons.account_balance_wallet, size: 14, color: Colors.purple),
      label: const Text('Wallet', style: TextStyle(fontSize: 12, color: Colors.purple)),
      style: TextButton.styleFrom(
        backgroundColor: Colors.purple.withValues(alpha: 0.1),
        padding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }

  void _showWalletAdjustDialog(BuildContext ctx, Map<String, dynamic> user, AdminController controller) {
    controller.walletUserId.value = user['id'];
    controller.walletAmount.value = '';
    controller.walletType.value = 'coins';
    controller.walletAction.value = 'add';

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: Text(
          'Adjust Wallet - ${user['name']}',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) => controller.walletAmount.value = value,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Amount',
                labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Coins', style: TextStyle(color: Colors.white)),
                    value: 'coins',
                    groupValue: controller.walletType.value,
                    onChanged: (value) {
                      if (value != null) controller.walletType.value = value;
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Diamonds', style: TextStyle(color: Colors.white)),
                    value: 'diamonds',
                    groupValue: controller.walletType.value,
                    onChanged: (value) {
                      if (value != null) controller.walletType.value = value;
                    },
                  ),
                ),
              ],
            )),
            Obx(() => Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Add', style: TextStyle(color: Colors.green)),
                    value: 'add',
                    groupValue: controller.walletAction.value,
                    onChanged: (value) {
                      if (value != null) controller.walletAction.value = value;
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Deduct', style: TextStyle(color: Colors.red)),
                    value: 'deduct',
                    groupValue: controller.walletAction.value,
                    onChanged: (value) {
                      if (value != null) controller.walletAction.value = value;
                    },
                  ),
                ),
              ],
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
          ),
          ElevatedButton(
            onPressed: () {
              controller.adjustWallet();
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}