// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/wallet/presentation/views/transaction_screen.dart
// ARVIND PARTY - TRANSACTION HISTORY SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/wallet_controller.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WalletController>();
    final selectedFilter = 'all'.obs;

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
          'Transactions',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => controller.fetchTransactions(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilterBar(selectedFilter, controller),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => controller.fetchTransactions(),
                child: Obx(() {
                  if (controller.isRefreshing.value && controller.transactions.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: Colors.orange));
                  }
                  if (controller.transactions.isEmpty) {
                    return _buildEmptyState();
                  }
                  final filtered = _applyFilter(controller.transactions, selectedFilter.value);
                  if (filtered.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final tx = filtered[index];
                      return _buildTransactionItem(tx);
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar(RxString selectedFilter, WalletController controller) {
    final filters = [
      {'key': 'all', 'label': 'All'},
      {'key': 'recharge', 'label': 'Recharge'},
      {'key': 'gift', 'label': 'Gifts'},
      {'key': 'withdrawal', 'label': 'Withdrawals'},
      {'key': 'exchange', 'label': 'Exchange'},
      {'key': 'reward', 'label': 'Rewards'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final f = filters[index];
            return Obx(() {
              final isActive = selectedFilter.value == f['key'];
              return GestureDetector(
                onTap: () {
                  selectedFilter.value = f['key']!;
                  final walletType = f['key'] == 'all' ? null : f['key'];
                  controller.fetchTransactions(walletType: walletType);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.orange.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isActive ? Colors.orange : Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    f['label']!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.orange : Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }

  List<dynamic> _applyFilter(List<dynamic> transactions, String filter) {
    if (filter == 'all') return transactions;
    return transactions.where((tx) {
      final type = tx.type.name.toLowerCase();
      switch (filter) {
        case 'recharge':
          return type == 'recharge';
        case 'gift':
          return type.contains('gift');
        case 'withdrawal':
          return type.contains('withdraw');
        case 'exchange':
          return type.contains('exchange');
        case 'reward':
          return type.contains('reward') || type.contains('bonus');
        default:
          return true;
      }
    }).toList();
  }

  Widget _buildTransactionItem(dynamic tx) {
    final isCredit = tx.amount >= 0;
    final icon = _getTransactionIcon(tx.type.name);
    final color = _getTransactionColor(tx.type.name);

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
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description ?? _formatType(tx.type.name),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(_formatDate(tx.createdAt), style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: _getStatusColor(tx.status.name).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(tx.status.name.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: _getStatusColor(tx.status.name))),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : ''}${tx.amount}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isCredit ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 2),
              Text(tx.currency.name, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.4))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 56, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text('No transactions found', style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.5))),
            const SizedBox(height: 8),
            Text('Your transactions will appear here', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.35))),
          ],
        ),
      ),
    );
  }

  IconData _getTransactionIcon(String type) {
    if (type.contains('recharge')) return Icons.add_circle_outline;
    if (type.contains('giftSent')) return Icons.card_giftcard_outlined;
    if (type.contains('giftReceived')) return Icons.redeem_outlined;
    if (type.contains('withdraw')) return Icons.arrow_upward_outlined;
    if (type.contains('exchangeIn')) return Icons.arrow_downward_outlined;
    if (type.contains('exchangeOut')) return Icons.swap_horiz_outlined;
    if (type.contains('reward') || type.contains('bonus')) return Icons.star_outline;
    if (type.contains('penalty')) return Icons.gavel_outlined;
    if (type.contains('tax')) return Icons.receipt_outlined;
    return Icons.circle_outlined;
  }

  Color _getTransactionColor(String type) {
    if (type.contains('recharge')) return Colors.green;
    if (type.contains('giftSent')) return Colors.pink;
    if (type.contains('giftReceived')) return Colors.purple;
    if (type.contains('withdraw')) return Colors.red;
    if (type.contains('exchangeIn')) return Colors.cyan;
    if (type.contains('exchangeOut')) return Colors.orange;
    if (type.contains('reward') || type.contains('bonus')) return Colors.amber;
    if (type.contains('penalty')) return Colors.red;
    if (type.contains('tax')) return Colors.grey;
    return Colors.white70;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.white70;
    }
  }

  String _formatType(String type) {
    return type.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}').trim();
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
