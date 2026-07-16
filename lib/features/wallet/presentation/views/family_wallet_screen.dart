// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/wallet/presentation/views/family_wallet_screen.dart
// ARVIND PARTY - FAMILY WALLET SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/wallet_controller.dart';

class FamilyWalletScreen extends StatelessWidget {
  const FamilyWalletScreen({super.key});

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
          'Family Wallet',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => controller.fetchFamilyWallet(),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => controller.fetchFamilyWallet(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFamilyBalanceCard(controller),
                const SizedBox(height: 24),
                _buildContributeCard(context, controller),
                const SizedBox(height: 24),
                _buildMemberContributions(controller),
                const SizedBox(height: 24),
                _buildFamilyTransactions(controller),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFamilyBalanceCard(WalletController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.pink.withValues(alpha: 0.2),
            Colors.red.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.pink.withValues(alpha: 0.3)),
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
                    colors: [Colors.pink, Colors.red],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.family_restroom_outlined, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      final name = controller.familyData.value?.name ?? 'Family';
                      return Text(name, style: const TextStyle(fontSize: 14, color: Colors.white70));
                    }),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                          '${controller.formatCurrency(controller.familyWalletData.value?.coins ?? 0)} coins',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() {
            final data = controller.familyWalletData.value;
            if (data == null) return const SizedBox.shrink();
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildMiniStat(
                      icon: Icons.diamond_outlined,
                      label: 'Diamonds',
                      value: controller.formatCurrency(data.diamonds),
                      color: Colors.cyan,
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _buildMiniStat(
                      icon: Icons.task_alt_outlined,
                      label: 'Task Earned',
                      value: controller.formatCurrency(data.taskCoinsEarned),
                      color: Colors.green,
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _buildMiniStat(
                      icon: Icons.card_giftcard_outlined,
                      label: 'Rewards',
                      value: controller.formatCurrency(data.rewardCoins),
                      color: Colors.purple,
                    )),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildMiniStat(
                      icon: Icons.date_range_outlined,
                      label: 'This Week',
                      value: controller.formatCurrency(data.weeklyEarned),
                      color: Colors.orange,
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _buildMiniStat(
                      icon: Icons.calendar_month_outlined,
                      label: 'This Month',
                      value: controller.formatCurrency(data.monthlyEarned),
                      color: Colors.teal,
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _buildMiniStat(
                      icon: controller.familyWalletData.value?.isFrozen == true ? Icons.lock_outlined : Icons.lock_open_outlined,
                      label: 'Status',
                      value: data.isFrozen ? 'Frozen' : 'Active',
                      color: data.isFrozen ? Colors.red : Colors.green,
                    )),
                  ],
                ),
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
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildContributeCard(BuildContext context, WalletController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.pink.withValues(alpha: 0.1),
            Colors.orange.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pink.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.volunteer_activism_outlined, color: Colors.pink, size: 20),
              SizedBox(width: 8),
              Text('Contribute to Family', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.contributionCoinsController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Coins',
                    prefixIcon: const Icon(Icons.monetization_on_outlined, color: Colors.orange),
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.pink),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller.contributionDiamondsController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Diamonds',
                    prefixIcon: const Icon(Icons.diamond_outlined, color: Colors.cyan),
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.pink),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: Obx(() => ElevatedButton(
                  onPressed: controller.isContributing.value
                      ? null
                      : () async => await controller.contributeToFamilyWallet(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: controller.isContributing.value
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Contribute', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberContributions(WalletController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Member Contributions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            Obx(() {
              final members = controller.memberContributions.length;
              return Text('$members members', style: TextStyle(fontSize: 13, color: Colors.pink.withValues(alpha: 0.8)));
            }),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.isFamilyWalletLoading.value) {
            return const Center(child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: Colors.pink),
            ));
          }
          if (controller.memberContributions.isEmpty) {
            return _buildEmptyState(Icons.group_outlined, 'No member contributions yet');
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.memberContributions.length,
            itemBuilder: (context, index) {
              final member = controller.memberContributions[index];
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
                      radius: 18,
                      backgroundColor: Colors.pink.withValues(alpha: 0.2),
                      child: Text(
                        member.uid.isNotEmpty ? member.uid[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(member.uid.isNotEmpty ? member.uid : member.userId, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                          const SizedBox(height: 2),
                          Text('${member.tasksCompleted} tasks completed', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('🪙 ${member.coinsContributed}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.orange)),
                        const SizedBox(height: 2),
                        Text('💎 ${member.diamondsContributed}', style: const TextStyle(fontSize: 12, color: Colors.cyan)),
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

  Widget _buildFamilyTransactions(WalletController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Family Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            TextButton(
              onPressed: () => controller.fetchFamilyTransactions(),
              child: Text('Refresh', style: TextStyle(fontSize: 12, color: Colors.pink.withValues(alpha: 0.8))),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.familyTransactions.isEmpty) {
            return _buildEmptyState(Icons.receipt_long_outlined, 'No family transactions yet');
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.familyTransactions.length.clamp(0, 10),
            itemBuilder: (context, index) {
              final tx = controller.familyTransactions[index];
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
                        color: Colors.pink.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        tx.amount >= 0 ? Icons.arrow_downward : Icons.arrow_upward,
                        color: tx.amount >= 0 ? Colors.green : Colors.red,
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
