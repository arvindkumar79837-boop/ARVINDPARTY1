import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('Transaction History', style: TextStyle(color: Colors.white, fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_outlined, color: Colors.white70),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSummaryBar(),
            Expanded(child: _buildTransactionList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.teal.withValues(alpha: 0.15),
            Colors.cyan.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.arrow_downward, color: Colors.green, size: 20),
                const SizedBox(height: 4),
                Text('+25,450', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                Text('Income', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.1)),
          Expanded(
            child: Column(
              children: [
                const Icon(Icons.arrow_upward, color: Colors.red, size: 20),
                const SizedBox(height: 4),
                Text('-18,200', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
                Text('Spent', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.1)),
          Expanded(
            child: Column(
              children: [
                Icon(Icons.account_balance_wallet, color: Colors.amber, size: 20),
                const SizedBox(height: 4),
                Text('+7,250', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
                Text('Net', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    final transactions = [
      {
        'title': 'Gift Sent',
        'desc': 'Sent gift to Priya in Live Room',
        'amount': -500,
        'type': 'debit',
        'date': 'Today, 3:45 PM',
        'icon': Icons.card_giftcard_outlined,
        'color': Colors.pink,
      },
      {
        'title': 'Stay Reward',
        'desc': 'Earned from family stay session',
        'amount': 120,
        'type': 'credit',
        'date': 'Today, 2:10 PM',
        'icon': Icons.stay_current_portrait,
        'color': Colors.green,
      },
      {
        'title': 'Coin Purchase',
        'desc': 'Recharged via Google Pay',
        'amount': 5000,
        'type': 'credit',
        'date': 'Yesterday, 8:30 PM',
        'icon': Icons.monetization_on_outlined,
        'color': Colors.amber,
      },
      {
        'title': 'Gift Sent',
        'desc': 'Sent gift to Rahul in Live Room',
        'amount': -200,
        'type': 'debit',
        'date': 'Yesterday, 6:15 PM',
        'icon': Icons.card_giftcard_outlined,
        'color': Colors.pink,
      },
      {
        'title': 'Daily Mission',
        'desc': 'Completed all daily missions',
        'amount': 50,
        'type': 'credit',
        'date': 'Jun 14, 11:00 PM',
        'icon': Icons.emoji_events_outlined,
        'color': Colors.amber,
      },
      {
        'title': 'Task Reward',
        'desc': 'Family task completed: Group Chat',
        'amount': 30,
        'type': 'credit',
        'date': 'Jun 14, 5:30 PM',
        'icon': Icons.task_alt,
        'color': Colors.blue,
      },
      {
        'title': 'Withdrawal',
        'desc': 'Bank transfer to HDFC ****4521',
        'amount': -3000,
        'type': 'debit',
        'date': 'Jun 13, 2:00 PM',
        'icon': Icons.account_balance_outlined,
        'color': Colors.orange,
      },
      {
        'title': 'Gift Received',
        'desc': 'Received gift from Sneha',
        'amount': 800,
        'type': 'credit',
        'date': 'Jun 12, 9:45 PM',
        'icon': Icons.card_giftcard,
        'color': Colors.purple,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final isCredit = tx['type'] == 'credit';
        final color = tx['color'] as Color;

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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(tx['icon'] as IconData, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tx['title'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(tx['desc'] as String, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isCredit ? '+' : ''}${tx['amount']} 🪙',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isCredit ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(tx['date'] as String, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.4))),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterDialog() {
    final selected = 'All'.obs;

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text('Filter Transactions', style: TextStyle(color: Colors.white)),
        content: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: ['All', 'Credits', 'Debits', 'Gifts', 'Rewards', 'Withdrawals'].map((f) {
                return RadioListTile<String>(
                  title: Text(f, style: const TextStyle(color: Colors.white)),
                  value: f,
                  groupValue: selected.value,
                  onChanged: (val) => selected.value = val!,
                  activeColor: Colors.teal,
                  contentPadding: EdgeInsets.zero,
                );
              }).toList(),
            )),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Apply', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
