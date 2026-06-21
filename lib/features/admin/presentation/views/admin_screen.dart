// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/admin/presentation/views/admin_screen.dart
// ARVIND PARTY - ADMIN SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';

class AdminScreen extends GetView<AdminController> {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Text(controller.errorMessage.value, style: const TextStyle(color: Colors.redAccent)),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ─── Stats Section ────────────────────────────────────────
    _buildSectionTitle('Dashboard Stats'),
    _buildStatsCard({
      'totalUsers': controller.totalUsers.value,
      'activeUsers': controller.activeUsers.value,
      'blockedUsers': controller.blockedUsers.value,
      'bannedUsers': controller.bannedUsers.value,
      'totalStaff': controller.totalStaff.value,
      'totalBroadcasts': controller.totalBroadcasts.value,
    }),
    const SizedBox(height: 24),

            // ─── User Management ──────────────────────────────────────
            _buildSectionTitle('User Management'),
            _buildUserList(context),
            const SizedBox(height: 24),

            // ─── Coin Control ─────────────────────────────────────────
            _buildSectionTitle('Coin Control'),
            _buildCoinControlForm(context),
            const SizedBox(height: 24),

            // ─── Withdrawal Management ────────────────────────────────
            _buildSectionTitle('Withdrawal Management'),
            _buildWithdrawalList(context),
            const SizedBox(height: 24),

            // ─── Send Reward ──────────────────────────────────────────
            _buildSectionTitle('Send Reward'),
            _buildSendRewardForm(context),
            const SizedBox(height: 24),
          ],
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white70),
      ),
    );
  }

  Widget _buildStatsCard(Map<String, dynamic>? stats) {
    if (stats == null) return const SizedBox.shrink();
    return Card(
      color: const Color(0xFF1A1A2E),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatItem('Total Users', stats['totalUsers']?.toString() ?? 'N/A', Icons.people),
            _buildStatItem('Active Rooms', stats['activeRooms']?.toString() ?? 'N/A', Icons.meeting_room),
            _buildStatItem('Total Revenue', stats['totalRevenue']?.toString() ?? 'N/A', Icons.monetization_on),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF8906)),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: Colors.white70)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildUserList(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A2E),
      margin: EdgeInsets.zero,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.users.length,
        itemBuilder: (ctx, index) {
          final user = controller.users[index];
          final isBlocked = user['isBlocked'] as bool? ?? false;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF2D2D44),
              backgroundImage: user['avatar'] != null ? NetworkImage(user['avatar']) : null,
              child: user['avatar'] == null ? Text(user['name']?[0] ?? '?', style: const TextStyle(color: Color(0xFFFF8906))) : null,
            ),
            title: Text(user['name'] ?? 'N/A', style: const TextStyle(color: Colors.white)),
            subtitle: Text('UID: ${user['uid'] ?? 'N/A'} | Coins: ${user['coins'] ?? 0}', style: const TextStyle(color: Colors.grey)),
            trailing: ElevatedButton(
              onPressed: () => controller.toggleUserBlock(user['_id']),
              style: ElevatedButton.styleFrom(
                backgroundColor: isBlocked ? Colors.green : Colors.redAccent,
                minimumSize: const Size(90, 36),
              ),
              child: Text(isBlocked ? 'Unblock' : 'Block', style: const TextStyle(color: Colors.white)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCoinControlForm(BuildContext context) {
    final uidController = TextEditingController();
    final amountController = TextEditingController();
    final reasonController = TextEditingController();

    return Card(
      color: const Color(0xFF1A1A2E),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: uidController,
              decoration: const InputDecoration(labelText: 'User UID', labelStyle: TextStyle(color: Colors.grey)),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (Coins)', labelStyle: TextStyle(color: Colors.grey)),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Reason', labelStyle: TextStyle(color: Colors.grey)),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.generateCoins(
                        uidController.text,
                        int.tryParse(amountController.text) ?? 0,
                        reasonController.text,
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Generate', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.deductCoins(
                        uidController.text,
                        int.tryParse(amountController.text) ?? 0,
                        reasonController.text,
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    child: const Text('Deduct', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawalList(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A2E),
      margin: EdgeInsets.zero,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.withdrawals.length,
        itemBuilder: (ctx, index) {
          final withdrawal = controller.withdrawals[index];
          final user = withdrawal['userId'] as Map<String, dynamic>?;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF2D2D44),
              backgroundImage: user?['avatar'] != null ? NetworkImage(user!['avatar']!) : null,
              child: user?['avatar'] == null ? Text(user?['name']?[0] ?? '?', style: const TextStyle(color: Color(0xFFFF8906))) : null,
            ),
            title: Text(user?['name'] ?? 'N/A', style: const TextStyle(color: Colors.white)),
            subtitle: Text('Amount: ${withdrawal['amount']} coins | Status: ${withdrawal['status']}', style: const TextStyle(color: Colors.grey)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () => controller.processWithdrawal(withdrawal['_id'], 'approved'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(70, 36)),
                  child: const Text('Approve', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => controller.processWithdrawal(withdrawal['_id'], 'rejected'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, minimumSize: const Size(70, 36)),
                  child: const Text('Reject', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSendRewardForm(BuildContext context) {
    final uidController = TextEditingController();
    final rewardTypeController = TextEditingController();
    final itemIdController = TextEditingController();
    final durationController = TextEditingController();
    final valueController = TextEditingController();

    return Card(
      color: const Color(0xFF1A1A2E),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: uidController,
              decoration: const InputDecoration(labelText: 'User UID', labelStyle: TextStyle(color: Colors.grey)),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: rewardTypeController,
              decoration: const InputDecoration(labelText: 'Reward Type (e.g., DIAMONDS, COINS, VIP)', labelStyle: TextStyle(color: Colors.grey)),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: itemIdController,
              decoration: const InputDecoration(labelText: 'Item ID (for FRAME, CAR etc.)', labelStyle: TextStyle(color: Colors.grey)),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Duration Days (for VIP, FRAME)', labelStyle: TextStyle(color: Colors.grey)),
              style: const TextStyle(color: Colors.white),
            ),
            TextField(
              controller: valueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Value (for DIAMONDS, COINS, VIP Level)', labelStyle: TextStyle(color: Colors.grey)),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                controller.sendReward({
                  'uid': uidController.text,
                  'rewardType': rewardTypeController.text.toUpperCase(),
                  if (itemIdController.text.isNotEmpty) 'itemId': itemIdController.text,
                  if (durationController.text.isNotEmpty) 'durationDays': int.tryParse(durationController.text) ?? 0,
                  if (valueController.text.isNotEmpty) 'value': int.tryParse(valueController.text) ?? 0,
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8906)),
              child: const Text('Send Reward', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
