import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RechargeHistoryScreen extends StatelessWidget {
  const RechargeHistoryScreen({super.key});

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
        title: const Text('Recharge History', style: TextStyle(color: Colors.white, fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_outlined, color: Colors.white70),
            onPressed: () {
              Get.bottomSheet(
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2A2A3E),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Filter Recharges', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.all_inclusive, color: Colors.amber),
                        title: const Text('All', style: TextStyle(color: Colors.white)),
                        onTap: () { Get.back(); },
                      ),
                      ListTile(
                        leading: const Icon(Icons.check_circle, color: Colors.green),
                        title: const Text('Completed Only', style: TextStyle(color: Colors.white)),
                        onTap: () { Get.back(); },
                      ),
                      ListTile(
                        leading: const Icon(Icons.schedule, color: Colors.orange),
                        title: const Text('Pending Only', style: TextStyle(color: Colors.white)),
                        onTap: () { Get.back(); },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 12),
            _buildStatusTabs(),
            const SizedBox(height: 8),
            Expanded(child: _buildRechargeList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF8906),
        onPressed: () => _showRechargeDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withValues(alpha: 0.15),
            Colors.orange.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Text('5', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber)),
                Text('Total Recharges', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
              ],
            ),
          ),
          Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.1)),
          Expanded(
            child: Column(
              children: [
                const Text('25,000', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                Text('Total Coins', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
              ],
            ),
          ),
          Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.1)),
          Expanded(
            child: Column(
              children: [
                const Text('₹2,500', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
                Text('Amount Paid', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const DefaultTabController(
        length: 3,
        child: TabBar(
          indicatorColor: Colors.amber,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.white54,
          labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: 'All'),
            Tab(text: 'Completed'),
            Tab(text: 'Pending'),
          ],
        ),
      ),
    );
  }

  Widget _buildRechargeList() {
    final recharges = [
      {'coins': 5000, 'amount': 500, 'status': 'completed', 'date': 'Jul 15, 2026', 'method': 'UPI', 'txId': 'TXN_8A4F2'},
      {'coins': 3000, 'amount': 300, 'status': 'completed', 'date': 'Jul 10, 2026', 'method': 'Card', 'txId': 'TXN_7B3E1'},
      {'coins': 10000, 'amount': 1000, 'status': 'completed', 'date': 'Jul 05, 2026', 'method': 'UPI', 'txId': 'TXN_6C2D0'},
      {'coins': 2000, 'amount': 200, 'status': 'pending', 'date': 'Jul 01, 2026', 'method': 'Net Banking', 'txId': 'TXN_5D1C9'},
      {'coins': 5000, 'amount': 500, 'status': 'completed', 'date': 'Jun 25, 2026', 'method': 'UPI', 'txId': 'TXN_4E0B8'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: recharges.length,
      itemBuilder: (context, index) {
        final r = recharges[index];
        final isCompleted = r['status'] == 'completed';

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
                  color: (isCompleted ? Colors.green : Colors.orange).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle_outline : Icons.schedule,
                  color: isCompleted ? Colors.green : Colors.orange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('${r['coins']} Coins',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.amber)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (isCompleted ? Colors.green : Colors.orange).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isCompleted ? 'Completed' : 'Pending',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isCompleted ? Colors.green : Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('₹${r['amount']} via ${r['method']} • ${r['date']}',
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
                    const SizedBox(height: 2),
                    Text('ID: ${r['txId']}', style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.3))),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRechargeDialog(BuildContext context) {
    final amountController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text('Recharge Coins', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add coins to your dealer wallet for transfers.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Number of Coins',
                  prefixIcon: const Icon(Icons.monetization_on, color: Colors.amber),
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.amber),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [1000, 3000, 5000, 10000].map((preset) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      child: OutlinedButton(
                        onPressed: () => amountController.text = '$preset',
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.amber.withValues(alpha: 0.3)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('${(preset / 1000).toInt()}k', style: const TextStyle(color: Colors.amber, fontSize: 12)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            onPressed: () {
              final coins = int.tryParse(amountController.text) ?? 0;
              if (coins > 0) {
                Get.back();
                Get.snackbar(
                  'Recharge Requested',
                  '$coins coins added to your wallet.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green.withValues(alpha: 0.8),
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text('Recharge', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
