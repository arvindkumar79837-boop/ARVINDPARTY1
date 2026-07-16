import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/agency_controller.dart';

class AgencyWalletManagementView extends StatelessWidget {
  const AgencyWalletManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AgencyController>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('Wallet Management', style: TextStyle(color: Colors.white, fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => controller.fetchWithdrawalHistory(),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => controller.fetchWithdrawalHistory(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBalanceOverview(),
                const SizedBox(height: 24),
                _buildQuickActionsSection(controller),
                const SizedBox(height: 24),
                _buildWithdrawalHistorySection(controller),
                const SizedBox(height: 24),
                _buildPaymentMethodsSection(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(alpha: 0.2),
            Colors.teal.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withValues(alpha: 0.35), width: 1.5),
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
                    colors: [Colors.green, Colors.teal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Agency Wallet', style: TextStyle(fontSize: 12, color: Colors.white70)),
                    SizedBox(height: 2),
                    Text('₹15,625.08', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(label: 'Available', value: '₹12,500', color: Colors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStat(label: 'Pending', value: '₹2,125', color: Colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStat(label: 'Withdrawn', value: '₹8,400', color: Colors.blue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.6))),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(AgencyController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.arrow_upward_outlined,
                label: 'Withdraw',
                color: Colors.green,
                onTap: () => _showWithdrawDialog(controller),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.swap_horiz_outlined,
                label: 'Transfer',
                color: Colors.blue,
                onTap: () => _showTransferDialog(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child:               _buildActionCard(
                icon: Icons.receipt_long_outlined,
                label: 'Statements',
                color: Colors.purple,
                onTap: () {
                  Get.snackbar('Statements', 'Monthly statements will be generated',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.purple.withValues(alpha: 0.8),
                      colorText: Colors.white);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawalHistorySection(AgencyController controller) {
    final withdrawals = [
      {'amount': 5000, 'date': 'Jul 10, 2026', 'status': 'completed', 'method': 'Bank Transfer'},
      {'amount': 3000, 'date': 'Jun 28, 2026', 'status': 'completed', 'method': 'UPI'},
      {'amount': 7500, 'date': 'Jun 15, 2026', 'status': 'processing', 'method': 'Bank Transfer'},
      {'amount': 2000, 'date': 'Jun 01, 2026', 'status': 'completed', 'method': 'UPI'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Withdrawal History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: withdrawals.length,
          itemBuilder: (context, index) {
            final w = withdrawals[index];
            final isCompleted = w['status'] == 'completed';

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
                      color: isCompleted ? Colors.green.withValues(alpha: 0.15) : Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isCompleted ? Icons.check_circle_outline : Icons.schedule,
                      color: isCompleted ? Colors.green : Colors.orange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('₹${w['amount']}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 2),
                        Text('${w['method']} • ${w['date']}', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.green.withValues(alpha: 0.15) : Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isCompleted ? 'Done' : 'Processing',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isCompleted ? Colors.green : Colors.orange),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsSection() {
    final methods = [
      {'name': 'HDFC Bank', 'detail': '****4521', 'icon': Icons.account_balance, 'color': Colors.blue, 'isDefault': true},
      {'name': 'Google Pay', 'detail': 'user@upi', 'icon': Icons.phone_android, 'color': Colors.green, 'isDefault': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Payment Methods', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            TextButton.icon(
              onPressed: () {
                Get.snackbar('Add Payment Method', 'Select UPI, Bank Account, or Card to add',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.orange.withValues(alpha: 0.8),
                    colorText: Colors.white);
              },
              icon: const Icon(Icons.add, size: 16, color: Colors.orange),
              label: const Text('Add', style: TextStyle(fontSize: 12, color: Colors.orange)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...methods.map((m) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: (m['color'] as Color).withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (m['color'] as Color).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(m['icon'] as IconData, color: m['color'] as Color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                        Text(m['detail'] as String, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
                      ],
                    ),
                  ),
                  if (m['isDefault'] as bool)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Default', style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            )),
      ],
    );
  }

  void _showWithdrawDialog(AgencyController controller) {
    final amountController = TextEditingController();
    final isProcessing = false.obs;

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text('Withdraw Funds', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Amount (₹)',
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
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
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
                        'Minimum withdrawal: ₹1,000. Processing time: 1-3 business days.',
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7)),
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
          Obx(() => ElevatedButton(
                onPressed: isProcessing.value
                    ? null
                    : () async {
                        final amount = double.tryParse(amountController.text);
                        if (amount == null || amount < 1000) {
                          Get.snackbar('Error', 'Minimum withdrawal is ₹1,000',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red.withValues(alpha: 0.8),
                              colorText: Colors.white);
                          return;
                        }
                        isProcessing.value = true;
                        Get.back();
                        Get.snackbar(
                          'Withdrawal Submitted',
                          '₹${amount.toStringAsFixed(2)} withdrawal request submitted.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green.withValues(alpha: 0.8),
                          colorText: Colors.white,
                        );
                      },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: isProcessing.value
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Withdraw', style: TextStyle(color: Colors.white)),
              )),
        ],
      ),
    );
  }

  void _showTransferDialog() {
    Get.snackbar(
      'Transfer',
      'Select a payment method to transfer funds',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.withValues(alpha: 0.8),
      colorText: Colors.white,
    );
  }
}
