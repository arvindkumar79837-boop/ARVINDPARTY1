// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/wallet/presentation/views/treasury_screen.dart
// ARVIND PARTY - TREASURY OVERVIEW SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/wallet_controller.dart';

class TreasuryScreen extends StatelessWidget {
  const TreasuryScreen({super.key});

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
          'Treasury',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => controller.fetchTreasuryData(),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => controller.fetchTreasuryData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTreasuryBalanceCard(controller),
                const SizedBox(height: 20),
                _buildTodayIncomeCard(controller),
                const SizedBox(height: 20),
                _buildOverviewStats(controller),
                const SizedBox(height: 20),
                _buildTreasuryTransactions(controller),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTreasuryBalanceCard(WalletController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.withValues(alpha: 0.2),
            Colors.deepPurple.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.indigo.withValues(alpha: 0.3)),
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
                    colors: [Colors.indigo, Colors.deepPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_outlined, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Treasury Balance', style: TextStyle(fontSize: 14, color: Colors.white70)),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                          controller.formatCurrencyDouble(controller.treasuryBalance.value.toDouble()),
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() {
            return Row(
              children: [
                Expanded(child: _buildMiniStat(
                  icon: Icons.trending_up_outlined,
                  label: 'Total Revenue',
                  value: '₹${controller.totalRevenue.value.toStringAsFixed(0)}',
                  color: Colors.green,
                )),
                const SizedBox(width: 10),
                Expanded(child: _buildMiniStat(
                  icon: Icons.receipt_long_outlined,
                  label: 'Transactions',
                  value: '${controller.totalTransactions.value}',
                  color: Colors.orange,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6))),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildTodayIncomeCard(WalletController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(alpha: 0.12),
            Colors.teal.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.today_outlined, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text("Today's Income", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final income = controller.todayIncome.value;
            if (income == null) {
              return Text('No data available', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.5)));
            }
            return Row(
              children: [
                Expanded(child: _buildIncomeStat('Total', '${income.total}', Colors.green)),
                Expanded(child: _buildIncomeStat('Expense', '${income.expense}', Colors.red)),
                Expanded(child: _buildIncomeStat('Net', '${income.netChange}', Colors.cyan)),
                Expanded(child: _buildIncomeStat('Tax', '₹${income.taxDeducted}', Colors.orange)),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildIncomeStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
      ],
    );
  }

  Widget _buildOverviewStats(WalletController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildOverviewCard(
              icon: Icons.monetization_on_outlined,
              label: 'Coin Balance',
              value: controller.formatCurrency(controller.coinBalance.value),
              color: Colors.orange,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildOverviewCard(
              icon: Icons.diamond_outlined,
              label: 'Diamond Balance',
              value: controller.formatCurrency(controller.diamondBalance.value),
              color: Colors.cyan,
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildOverviewCard(
              icon: Icons.star_outline,
              label: 'Pending Withdrawals',
              value: '${controller.pendingWithdrawals.value}',
              color: Colors.yellow,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildOverviewCard(
              icon: Icons.percent_outlined,
              label: 'Tax Rate',
              value: '${controller.taxPercentage.value}%',
              color: Colors.purple,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
        ],
      ),
    );
  }

  Widget _buildTreasuryTransactions(WalletController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.treasuryTransactions.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 40, color: Colors.white.withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                    Text('No treasury transactions yet', style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.5))),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.treasuryTransactions.length.clamp(0, 10),
            itemBuilder: (context, index) {
              final tx = controller.treasuryTransactions[index];
              final amount = (tx['amount'] ?? 0).toDouble();
              final desc = tx['description'] ?? 'Treasury transaction';
              final createdAt = tx['createdAt'] != null ? DateTime.tryParse(tx['createdAt']) : null;
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
                        color: Colors.indigo.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        amount >= 0 ? Icons.arrow_downward : Icons.arrow_upward,
                        color: amount >= 0 ? Colors.green : Colors.red,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(desc, style: const TextStyle(fontSize: 13, color: Colors.white)),
                          if (createdAt != null)
                            Text(_formatDate(createdAt), style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
                        ],
                      ),
                    ),
                    Text(
                      '${amount >= 0 ? '+' : ''}₹${amount.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: amount >= 0 ? Colors.green : Colors.red),
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
