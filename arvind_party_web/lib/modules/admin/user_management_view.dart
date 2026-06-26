// ═══════════════════════════════════════════════════════════════════════════
// MODULE: Admin User Management Dashboard
// ARVIND PARTY - Web Admin Panel
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class UserManagementView extends GetView<UserManagementController> {
  const UserManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: controller.showSearchDialog,
            tooltip: 'Search Users',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadUsers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.users.isEmpty) {
                return const Center(child: Text('No users found', style: TextStyle(color: Colors.grey)));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: controller.users.length,
                itemBuilder: (context, index) => _buildUserCard(controller.users[index]),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('Total Users', controller.totalUsers.toString(), Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('Active', controller.activeUsers.toString(), Colors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('Banned', controller.bannedUsers.toString(), Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final userId = user['_id'] ?? '';
    final uid = user['uid'] ?? '';
    final name = user['name'] ?? 'Unknown';
    final avatar = user['avatar'] ?? '';
    final level = user['level'] ?? 0;
    final vipLevel = user['vipLevel'] ?? 0;
    final coins = user['coins'] ?? 0;
    final diamonds = user['diamonds'] ?? 0;
    final isBanned = user['isBanned'] ?? false;
    final createdAt = user['createdAt'] != null 
        ? DateTime.parse(user['createdAt']).toString().split(' ')[0]
        : 'N/A';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
          child: avatar.isEmpty ? Text(name[0].toUpperCase()) : null,
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('UID: $uid | Level: $level | VIP: $vipLevel'),
            Text('Coins: $coins | Diamonds: $diamonds | Joined: $createdAt'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(isBanned ? Icons.person_add : Icons.block, color: isBanned ? Colors.green : Colors.red),
              onPressed: () => controller.toggleBan(userId, !isBanned),
              tooltip: isBanned ? 'Unban User' : 'Ban User',
            ),
            IconButton(
              icon: const Icon(Icons.account_balance_wallet, color: Colors.orange),
              onPressed: () => controller.showAdjustBalanceDialog(userId, name),
              tooltip: 'Adjust Balance',
            ),
          ],
        ),
      ),
    );
  }
}

class UserManagementController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final RxList<Map<String, dynamic>> users = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt totalUsers = 0.obs;
  final RxInt activeUsers = 0.obs;
  final RxInt bannedUsers = 0.obs;
  int currentPage = 1;
  static const int pageSize = 50;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  Future<void> loadUsers({String? search}) async {
    isLoading.value = true;
    try {
      final endpoint = search != null 
          ? '/api/admin/search?q=$search&type=users'
          : '/api/admin/users?page=$currentPage&limit=$pageSize';
      
      final response = await _api.get(endpoint);
      if (response['success'] == true) {
        final data = response['data'] as List;
        users.assignAll(data.map((e) => Map<String, dynamic>.from(e)).toList());
        totalUsers.value = response['pagination']?['total'] ?? data.length;
        bannedUsers.value = users.where((u) => u['isBanned'] == true).length;
        activeUsers.value = totalUsers.value - bannedUsers.value;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load users: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleBan(String userId, bool isBanned) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(isBanned ? 'Ban User' : 'Unban User'),
        content: Text('Are you sure you want to ${isBanned ? 'ban' : 'unban'} this user?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await _api.post('/api/admin/users/ban', {
        'userId': userId,
        'isBanned': isBanned,
        'reason': isBanned ? 'Admin action' : '',
      });

      if (response['success'] == true) {
        Get.snackbar('Success', response['message'], backgroundColor: Colors.green, colorText: Colors.black);
        loadUsers();
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to update ban status', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Operation failed: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> showAdjustBalanceDialog(String userId, String userName) async {
    final coinsController = TextEditingController();
    final diamondsController = TextEditingController();

    final result = await Get.dialog<Map<String, dynamic>>(
      AlertDialog(
        title: Text('Adjust Balance - $userName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: coinsController,
              decoration: const InputDecoration(labelText: 'Coins (positive/negative)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: diamondsController,
              decoration: const InputDecoration(labelText: 'Diamonds (positive/negative)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final coins = int.tryParse(coinsController.text) ?? 0;
              final diamonds = int.tryParse(diamondsController.text) ?? 0;
              Get.back(result: {'coins': coins, 'diamonds': diamonds});
            },
            child: const Text('Adjust'),
          ),
        ],
      ),
    );

    if (result == null) return;

    try {
      final response = await _api.post('/api/admin/users/adjust-coins/$userId', result);
      if (response['success'] == true) {
        Get.snackbar('Success', 'Balance updated', backgroundColor: Colors.green, colorText: Colors.black);
        loadUsers();
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to adjust balance', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Operation failed: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void showSearchDialog() {
    final searchController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Search Users'),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(labelText: 'Search by UID or Name', border: OutlineInputBorder()),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final query = searchController.text.trim();
              if (query.isNotEmpty) {
                Get.back();
                loadUsers(search: query);
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}