import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/dealer_model.dart';
import '../controllers/dealer_controller.dart';

class DealerWalletScreen extends StatelessWidget {
  const DealerWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DealerController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dealer Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.fetchDealerWallet();
              controller.fetchDealerStats();
              controller.fetchDealerTransactions();
            },
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.wallet.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final wallet = controller.wallet.value;
        final stats = controller.stats.value;

        if (wallet == null) {
          return const Center(child: Text('No dealer wallet found'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBalanceCard(controller, wallet),
              const SizedBox(height: 16),
              _buildLevelCard(wallet),
              const SizedBox(height: 16),
              if (stats != null) _buildTodayCard(stats.today, controller),
              const SizedBox(height: 16),
              _buildTransferForm(controller),
              const SizedBox(height: 16),
              _buildRefundForm(controller),
              const SizedBox(height: 16),
              const Text(
                'Recent Transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                }
                if (controller.transactions.isEmpty) {
                  return const Card(child: ListTile(title: Text('No transactions found')));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.transactions.length,
                  itemBuilder: (context, index) {
                    final tx = controller.transactions[index];
                    final isDebit = tx['amount'] is num && (tx['amount'] as num) < 0;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(isDebit ? Icons.arrow_upward : Icons.arrow_downward, color: isDebit ? Colors.red : Colors.green),
                        title: Text(tx['description'] ?? 'Transaction'),
                        subtitle: Text('${tx['type'] ?? ''} | ${_formatDate(tx['createdAt'])}'),
                        trailing: Text(
                          '${isDebit ? '-' : '+'}${tx['amount'] ?? 0}',
                          style: TextStyle(color: isDebit ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBalanceCard(DealerController controller, DealerWalletModel wallet) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Current Balance', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              '${_formatCurrency(wallet.balance)} Coins',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildMiniStat('Received', wallet.totalReceived)),
                Expanded(child: _buildMiniStat('Transferred', wallet.totalTransferred)),
                Expanded(child: _buildMiniStat('Refunded', wallet.totalRefunded)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(_formatCurrency(value), style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildLevelCard(DealerWalletModel wallet) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.workspace_premium, color: _levelColor(wallet.level)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${wallet.level.name.toUpperCase()} Dealer', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Commission: ${wallet.commissionPercent}% | Bonus: ${wallet.bonusPercent}%', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            if (!wallet.isVerified)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: const Text('Unverified', style: TextStyle(color: Colors.orange, fontSize: 12)),
              )
          ],
        ),
      ),
    );
  }

  Color _levelColor(DealerLevel level) {
    if (level == DealerLevel.gold) return Colors.amber;
    if (level == DealerLevel.diamond) return Colors.blue;
    return Colors.grey;
  }

  Widget _buildTodayCard(DayStats today, DealerController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Today', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildMiniStat('Transfers', today.transfersCount)),
                Expanded(child: _buildMiniStat('Volume', today.volume.toInt())),
                Expanded(child: _buildMiniStat('Remaining', today.remainingLimit.toInt())),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTransferForm(DealerController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Transfer Coins to User', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: controller.targetUidController,
              decoration: const InputDecoration(labelText: 'Target UID', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder(), prefixIcon: Icon(Icons.monetization_on)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.reasonController,
              decoration: const InputDecoration(labelText: 'Reason (optional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.descriptionController,
              decoration: const InputDecoration(labelText: 'Description (optional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.isLoading.value ? null : controller.transferCoinsToUser,
                icon: const Icon(Icons.send),
                label: Text(controller.isLoading.value ? 'Processing...' : 'Transfer Now'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRefundForm(DealerController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Request Refund', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: controller.refundTransactionHashController,
              decoration: const InputDecoration(labelText: 'Transaction Hash', border: OutlineInputBorder(), prefixIcon: Icon(Icons.fingerprint)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.refundCoinsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Coins to Refund', border: OutlineInputBorder(), prefixIcon: Icon(Icons.monetization_on)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.refundReasonController,
              decoration: const InputDecoration(labelText: 'Reason', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.refundErrorDescriptionController,
              decoration: const InputDecoration(labelText: 'Error Description (optional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.isLoading.value ? null : controller.requestRefund,
                icon: const Icon(Icons.replay),
                label: Text(controller.isLoading.value ? 'Submitting...' : 'Submit Refund Request'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }

  String _formatCurrency(int amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toString();
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return '';
    try {
      final dt = DateTime.parse(dateValue.toString());
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateValue.toString();
    }
  }
}