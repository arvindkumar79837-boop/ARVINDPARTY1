import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/coin_seller_controller.dart';

class SettlementHistoryScreen extends StatelessWidget {
  const SettlementHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CoinSellerController>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('Settlement History', style: TextStyle(color: Colors.white, fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => controller.loadDealerData(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 16),
            Expanded(child: _buildSettlementList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF8906),
        onPressed: () => _showSettleDialog(context),
        child: const Icon(Icons.account_balance, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(alpha: 0.15),
            Colors.teal.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.green, Colors.teal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Settlement Balance', style: TextStyle(fontSize: 12, color: Colors.white70)),
                    SizedBox(height: 2),
                    Text('₹6,300', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMiniStat('Total Settled', '₹18,200', Colors.green),
              const SizedBox(width: 12),
              _buildMiniStat('Pending', '₹6,300', Colors.orange),
              const SizedBox(width: 12),
              _buildMiniStat('Settlements', '8', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: 0.5))),
          ],
        ),
      ),
    );
  }

  Widget _buildSettlementList() {
    final settlements = [
      {
        'amount': 5000.0,
        'status': 'completed',
        'date': 'Jul 12, 2026',
        'method': 'Bank Transfer',
        'account': 'HDFC ****4521',
        'refId': 'STL_9C3A1',
        'processingTime': '1 day',
      },
      {
        'amount': 3200.0,
        'status': 'completed',
        'date': 'Jul 01, 2026',
        'method': 'UPI',
        'account': 'user@upi',
        'refId': 'STL_8B2E0',
        'processingTime': 'Same day',
      },
      {
        'amount': 6000.0,
        'status': 'processing',
        'date': 'Jun 25, 2026',
        'method': 'Bank Transfer',
        'account': 'HDFC ****4521',
        'refId': 'STL_7A1D9',
        'processingTime': 'In progress',
      },
      {
        'amount': 2000.0,
        'status': 'completed',
        'date': 'Jun 18, 2026',
        'method': 'UPI',
        'account': 'user@upi',
        'refId': 'STL_6C0B8',
        'processingTime': 'Same day',
      },
      {
        'amount': 2000.0,
        'status': 'rejected',
        'date': 'Jun 10, 2026',
        'method': 'Bank Transfer',
        'account': 'HDFC ****4521',
        'refId': 'STL_5D9A7',
        'processingTime': 'N/A',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: settlements.length,
      itemBuilder: (context, index) {
        final s = settlements[index];
        final status = s['status'] as String;
        final color = status == 'completed'
            ? Colors.green
            : status == 'processing'
                ? Colors.orange
                : Colors.red;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      status == 'completed'
                          ? Icons.check_circle_outline
                          : status == 'processing'
                              ? Icons.hourglass_top
                              : Icons.cancel_outlined,
                      color: color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₹${(s['amount'] as double).toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text('${s['method']} • ${s['account']}', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${status[0].toUpperCase()}${status.substring(1)}',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _buildDetailChip(Icons.calendar_today, s['date'] as String),
                    const SizedBox(width: 12),
                    _buildDetailChip(Icons.receipt_outlined, s['refId'] as String),
                    const SizedBox(width: 12),
                    _buildDetailChip(Icons.access_time, s['processingTime'] as String),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.4)),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.5))),
      ],
    );
  }

  void _showSettleDialog(BuildContext context) {
    final amountController = TextEditingController();
    final selectedMethod = 'bank_transfer'.obs;

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text('Request Settlement', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Available balance: ₹6,300',
                style: TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Settlement Amount (₹)',
                  prefixIcon: const Icon(Icons.currency_rupee, color: Colors.green),
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Settlement Method', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7))),
              const SizedBox(height: 8),
              Obx(() => Row(
                    children: [
                      Expanded(
                        child: _buildMethodOption(
                          'bank_transfer',
                          'Bank Transfer',
                          Icons.account_balance,
                          'HDFC ****4521',
                          selectedMethod,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMethodOption(
                          'upi',
                          'UPI',
                          Icons.phone_android,
                          'user@upi',
                          selectedMethod,
                        ),
                      ),
                    ],
                  )),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Settlements are processed within 1-3 business days. Minimum: ₹500.',
                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount < 500) {
                Get.snackbar('Error', 'Minimum settlement is ₹500',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.withValues(alpha: 0.8),
                    colorText: Colors.white);
                return;
              }
              Get.back();
              Get.snackbar(
                'Settlement Requested',
                '₹${amount.toStringAsFixed(0)} settlement request submitted.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green.withValues(alpha: 0.8),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Submit Request', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodOption(
    String value,
    String title,
    IconData icon,
    String detail,
    RxString selectedMethod,
  ) {
    final isSelected = selectedMethod.value == value;
    return GestureDetector(
      onTap: () => selectedMethod.value = value,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.green.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: isSelected ? Colors.green : Colors.white54, size: 18),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : Colors.white54)),
              ],
            ),
            const SizedBox(height: 4),
            Text(detail, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.4))),
          ],
        ),
      ),
    );
  }
}
