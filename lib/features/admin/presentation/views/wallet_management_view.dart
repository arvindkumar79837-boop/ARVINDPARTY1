import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../features/wallet/presentation/controllers/wallet_controller.dart';

class AdminWalletManagementView extends StatelessWidget {
  const AdminWalletManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WalletController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.loadAllData();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBalanceCard('Coin Balance', controller.coinBalance.value, Icons.monetization_on, Colors.amber),
            const SizedBox(height: 16),
            _buildBalanceCard('Diamond Balance', controller.diamondBalance.value, Icons.diamond, Colors.cyan),
            const SizedBox(height: 16),
            _buildBalanceCard('Pending Withdrawals', controller.pendingWithdrawals.value, Icons.pending_actions, Colors.orange),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/admin/withdrawals'),
              icon: const Icon(Icons.list),
              label: const Text('Manage Withdrawals'),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildBalanceCard(String title, int value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    value.toString(),
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}