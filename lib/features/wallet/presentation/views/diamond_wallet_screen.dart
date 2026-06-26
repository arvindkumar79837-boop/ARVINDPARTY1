import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/wallet_controller.dart';
import '../models/wallet_model.dart';

class DiamondWalletScreen extends StatelessWidget {
  const DiamondWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WalletController controller = Get.find<WalletController>();

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
          'Diamond Wallet',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => await controller.loadAllData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBalanceCard(controller),
                const SizedBox(height: 24),
                _buildExchangeCard(controller),
                const SizedBox(height: 24),
                _buildTransactionHistory(controller),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(WalletController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withAlpha(51),
            Colors.lightBlue.withAlpha(26),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.blue.withAlpha(77),
          width: 1,
        ),
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
                    colors: [Colors.blue, Colors.lightBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.diamond_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Diamonds',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                          controller.formatCurrency(controller.diamondBalance.value),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  icon: Icons.trending_up_outlined,
                  label: 'Buy Rate',
                  value: '₹${controller.diamondBuyRate.value.toStringAsFixed(1)}',
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: _buildMiniStat(
                  icon: Icons.swap_horiz_outlined,
                  label: 'To Coins',
                  value: '1/${controller.exchangeRate.value} 💎→🪙',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
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
        color: Colors.white.withAlpha(13),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withAlpha(153),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeCard(WalletController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withAlpha(26),
            Colors.purple.withAlpha(26),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.swap_horiz_outlined,
                color: Colors.blue,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Quick Exchange',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(51),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.monetization_on_outlined,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Diamonds to Coins',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withAlpha(179),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Obx(() => Text(
                            'Rate: ${controller.exchangeRate.value} 💎 = 1 🪙',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          )),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Get.snackbar(
                    'Exchange',
                    'Please use main wallet for exchange',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.blue.withAlpha(204),
                    colorText: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'Exchange',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory(WalletController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Diamond Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextButton.icon(
              onPressed: () => controller.fetchTransactions(walletType: 'diamond'),
              icon: Icon(
                Icons.refresh,
                size: 14,
                color: Colors.blue.withAlpha((0.8 * 255).round()),
              ),
              label: Text(
                'Refresh',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.withAlpha((0.8 * 255).round()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isRefreshing.value &&
              controller.transactions.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              ),
            );
          }

          if (controller.transactions.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.diamond_outlined,
                      size: 48,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No diamond transactions yet',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withAlpha(128),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.transactions.length,
            itemBuilder: (context, index) {
              final tx = controller.transactions[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withAlpha(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getTxColor(tx.type).withAlpha((0.15 * 255).round()),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getTxIcon(tx.type),
                        color: _getTxColor(tx.type),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.description ?? _getTxLabel(tx.type),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(tx.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withAlpha(128),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${tx.amount >= 0 ? '+' : ''}${tx.amount}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: tx.amount >= 0 ? Colors.green : Colors.red,
                      ),
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

  IconData _getTxIcon(TransactionType type) {
    switch (type) {
      case TransactionType.recharge:
        return Icons.add_circle_outline;
      case TransactionType.withdrawal:
        return Icons.arrow_circle_right_outlined;
      case TransactionType.giftSent:
        return Icons.card_giftcard_outlined;
      case TransactionType.giftReceived:
        return Icons.card_giftcard;
      case TransactionType.eventReward:
        return Icons.emoji_events_outlined;
      case TransactionType.exchangeIn:
      case TransactionType.exchangeOut:
        return Icons.swap_horiz;
      case TransactionType.reward:
      case TransactionType.bonus:
        return Icons.card_giftcard;
      case TransactionType.taxDeducted:
      case TransactionType.penalty:
        return Icons.money_off;
      case TransactionType.freezeAdjustment:
        return Icons.lock;
      case TransactionType.unfreezeAdjustment:
        return Icons.lock_open;
      case TransactionType.dailyTaskReward:
      case TransactionType.loginStreakReward:
        return Icons.task_alt;
      case TransactionType.familyTaskReward:
      case TransactionType.familyContribution:
        return Icons.group;
      case TransactionType.agencyCommission:
      case TransactionType.agencyHostEarning:
      case TransactionType.agencyWithdrawal:
        return Icons.business;
      case TransactionType.adminAdjust:
        return Icons.admin_panel_settings;
      case TransactionType.refund:
        return Icons.refresh;
      case TransactionType.treasureHuntReward:
      case TransactionType.luckyDrawReward:
      case TransactionType.tournamentReward:
        return Icons.emoji_events;
    }
  }

  Color _getTxColor(TransactionType type) {
    if (type == TransactionType.recharge || type == TransactionType.exchangeIn || type == TransactionType.reward || type == TransactionType.bonus || type == TransactionType.refund) return Colors.green;
    if (type == TransactionType.withdrawal || type == TransactionType.giftSent || type == TransactionType.taxDeducted || type == TransactionType.penalty) return Colors.red;
    if (type == TransactionType.giftReceived) return Colors.pink;
    if (type == TransactionType.freezeAdjustment) return Colors.red.shade400;
    if (type == TransactionType.unfreezeAdjustment) return Colors.green.shade400;
    if (type == TransactionType.dailyTaskReward || type == TransactionType.loginStreakReward || type == TransactionType.eventReward) return Colors.blue;
    if (type == TransactionType.familyTaskReward || type == TransactionType.familyContribution) return Colors.teal;
    if (type == TransactionType.agencyCommission || type == TransactionType.agencyHostEarning) return Colors.deepPurple;
    if (type == TransactionType.adminAdjust) return Colors.orange;
    return Colors.grey;
  }

  String _getTxLabel(TransactionType type) {
    switch (type) {
      case TransactionType.recharge:
        return 'Recharge';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.giftSent:
        return 'Gift Sent';
      case TransactionType.giftReceived:
        return 'Gift Received';
      case TransactionType.eventReward:
        return 'Event Reward';
      case TransactionType.exchangeIn:
        return 'Coin Exchange In';
      case TransactionType.exchangeOut:
        return 'Diamond Exchange Out';
      case TransactionType.reward:
      case TransactionType.bonus:
        return 'Reward/Bonus';
      case TransactionType.dailyTaskReward:
        return 'Daily Task';
      case TransactionType.loginStreakReward:
        return 'Login Streak';
      case TransactionType.familyTaskReward:
        return 'Family Task';
      case TransactionType.familyContribution:
        return 'Family Contribution';
      case TransactionType.agencyCommission:
        return 'Agency Commission';
      case TransactionType.agencyHostEarning:
        return 'Host Earning';
      case TransactionType.agencyWithdrawal:
        return 'Agency Withdrawal';
      case TransactionType.taxDeducted:
        return 'Tax Deducted';
      case TransactionType.penalty:
        return 'Penalty';
      case TransactionType.freezeAdjustment:
        return 'Wallet Frozen';
      case TransactionType.unfreezeAdjustment:
        return 'Wallet Unfrozen';
      case TransactionType.adminAdjust:
        return 'Admin Adjustment';
      case TransactionType.refund:
        return 'Refund';
      case TransactionType.treasureHuntReward:
      case TransactionType.luckyDrawReward:
      case TransactionType.tournamentReward:
        return 'Game Reward';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';

    return '${date.day}/${date.month}/${date.year}';
  }
}