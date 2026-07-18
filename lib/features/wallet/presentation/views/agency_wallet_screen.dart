// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/wallet/presentation/views/agency_wallet_screen.dart
// ARVIND PARTY - AGENCY WALLET SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../controllers/wallet_controller.dart';

class AgencyWalletScreen extends StatelessWidget {
  const AgencyWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WalletController>();

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
          'Agency Wallet',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => controller.fetchAgencyWallet(),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => controller.fetchAgencyWallet(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAgencyBalanceCard(controller),
                const SizedBox(height: 20),
                _buildQuickActions(controller),
                const SizedBox(height: 20),
                _buildHostsSection(controller),
                const SizedBox(height: 20),
                _buildAgencyTransactions(controller),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAgencyBalanceCard(WalletController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.teal.withValues(alpha: 0.2),
            Colors.cyan.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.teal, Colors.cyan],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.business_center_outlined, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Agency Balance', style: TextStyle(fontSize: 14, color: Colors.white70)),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                          controller.formatCurrency(controller.agencyWalletData.value?.balance ?? 0),
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() {
            final data = controller.agencyWalletData.value;
            if (data == null) return const SizedBox.shrink();
            return Row(
              children: [
                Expanded(child: _buildMiniStat(
                  icon: Icons.trending_up_outlined,
                  label: 'Total Earnings',
                  value: controller.formatCurrency(data.totalEarnings),
                  color: Colors.green,
                )),
                const SizedBox(width: 10),
                Expanded(child: _buildMiniStat(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Total Withdrawn',
                  value: controller.formatCurrency(data.totalWithdrawn),
                  color: Colors.orange,
                )),
                const SizedBox(width: 10),
                Expanded(child: _buildMiniStat(
                  icon: Icons.hourglass_top_outlined,
                  label: 'Pending',
                  value: controller.formatCurrency(data.pendingWithdrawal),
                  color: Colors.yellow,
                )),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 3),
              Flexible(
                child: Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.6)), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildQuickActions(WalletController controller) {
    return Row(
      children: [
        Expanded(child: _buildActionButton(
          icon: Icons.money_off_outlined,
          label: 'Withdraw',
          color: Colors.red,
          onTap: () {
            Get.defaultDialog(
              title: 'Agency Withdrawal',
              titleStyle: const TextStyle(color: Colors.white, fontSize: 18),
              backgroundColor: const Color(0xFF1A1A2E),
              content: _buildWithdrawDialog(controller),
              confirm: const SizedBox.shrink(),
              cancel: const SizedBox.shrink(),
            );
          },
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildActionButton(
          icon: Icons.group_outlined,
          label: 'Transfer to Host',
          color: Colors.blue,
          onTap: () {
            Get.defaultDialog(
              title: 'Transfer to Host',
              titleStyle: const TextStyle(color: Colors.white, fontSize: 18),
              backgroundColor: const Color(0xFF1A1A2E),
              content: _buildTransferDialog(controller),
              confirm: const SizedBox.shrink(),
              cancel: const SizedBox.shrink(),
            );
          },
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildActionButton(
          icon: Icons.analytics_outlined,
          label: 'Analytics',
          color: Colors.purple,
          onTap: () => Get.toNamed(AppRoutes.agencyEarnings),
        )),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferDialog(WalletController controller) {
    final hostIdController = TextEditingController();
    final amountController = TextEditingController();
    return SizedBox(
      width: 300,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: hostIdController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Host ID',
                hintText: 'Enter host ID',
                prefixIcon: const Icon(Icons.person_outlined, color: Colors.blue),
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Amount (coins)',
                hintText: 'Enter amount',
                prefixIcon: const Icon(Icons.monetization_on_outlined, color: Colors.blue),
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  if (hostIdController.text.isEmpty || amountController.text.isEmpty) {
                    Get.snackbar('Error', 'Please fill in all fields', snackPosition: SnackPosition.BOTTOM);
                    return;
                  }
                  Get.back();
                  Get.snackbar('Success', 'Transfer request sent successfully', snackPosition: SnackPosition.BOTTOM);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                ),
                child: const Text('Transfer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawDialog(WalletController controller) {
    return SizedBox(
      width: 300,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller.withdrawAmountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Amount (coins)',
                hintText: 'Enter amount',
                prefixIcon: const Icon(Icons.monetization_on_outlined, color: Colors.teal),
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.teal),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: Obx(() => ElevatedButton(
                    onPressed: controller.isProcessingWithdraw.value
                        ? null
                        : () async {
                            Get.back();
                            await controller.requestAgencyWithdrawal();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    ),
                    child: controller.isProcessingWithdraw.value
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Withdraw', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHostsSection(WalletController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Agency Hosts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            Obx(() => Text(
                  '${controller.agencyHosts.length} hosts',
                  style: TextStyle(fontSize: 13, color: Colors.teal.withValues(alpha: 0.8)),
                )),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.isAgencyWalletLoading.value) {
            return const Center(child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: Colors.teal),
            ));
          }
          if (controller.agencyHosts.isEmpty) {
            return _buildEmptyState(Icons.group_outlined, 'No hosts in your agency yet');
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.agencyHosts.length,
            itemBuilder: (context, index) {
              final host = controller.agencyHosts[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.teal.withValues(alpha: 0.2),
                      child: Text(
                        host.name.isNotEmpty ? host.name[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(host.name.isNotEmpty ? host.name : host.uid, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                          const SizedBox(height: 2),
                          Text('💎 ${host.diamonds} diamonds', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${controller.formatCurrency(host.estimatedAgencyEarning)} coins', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.green)),
                        const SizedBox(height: 2),
                        Text('commission', style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.4))),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildAgencyTransactions(WalletController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Agency Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            TextButton(
              onPressed: () => controller.fetchAgencyTransactions(),
              child: Text('Refresh', style: TextStyle(fontSize: 12, color: Colors.teal.withValues(alpha: 0.8))),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.agencyTransactions.isEmpty) {
            return _buildEmptyState(Icons.receipt_long_outlined, 'No agency transactions yet');
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.agencyTransactions.length.clamp(0, 10),
            itemBuilder: (context, index) {
              final tx = controller.agencyTransactions[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        tx.type.name.contains('withdraw') ? Icons.arrow_upward : Icons.arrow_downward,
                        color: tx.type.name.contains('withdraw') ? Colors.red : Colors.green,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tx.description ?? tx.type.name, style: const TextStyle(fontSize: 13, color: Colors.white)),
                          const SizedBox(height: 2),
                          Text(_formatDate(tx.createdAt), style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
                        ],
                      ),
                    ),
                    Text(
                      '${tx.amount >= 0 ? '+' : ''}${tx.amount}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: tx.amount >= 0 ? Colors.green : Colors.red),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.white.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text(message, style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.5))),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
