// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/wallet/presentation/views/withdrawal_screen.dart
// ARVIND PARTY - WITHDRAWAL REQUEST SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/wallet_controller.dart';

class WithdrawalScreen extends StatelessWidget {
  const WithdrawalScreen({super.key});

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
          'Withdrawal',
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
                _buildWithdrawForm(context, controller),
                const SizedBox(height: 24),
                _buildWithdrawalInfo(controller),
                const SizedBox(height: 24),
                _buildWithdrawalHistory(controller),
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
            Colors.teal.withValues(alpha: 0.2),
            Colors.blue.withValues(alpha: 0.1),
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
                    colors: [Colors.teal, Colors.blue],
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
                    const Text('Available Balance', style: TextStyle(fontSize: 14, color: Colors.white70)),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                          '${controller.formatCurrency(controller.diamondBalance.value)} diamonds',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildMiniStat(
                icon: Icons.diamond_outlined,
                label: 'Diamonds',
                value: '${controller.diamondBalance.value}',
                color: Colors.cyan,
              )),
              const SizedBox(width: 10),
              Expanded(child: _buildMiniStat(
                icon: Icons.money_outlined,
                label: 'Min Withdrawal',
                value: '₹${controller.minWithdrawal.value}',
                color: Colors.green,
              )),
              const SizedBox(width: 10),
              Expanded(child: _buildMiniStat(
                icon: Icons.pending_outlined,
                label: 'Pending',
                value: '${controller.pendingWithdrawals.value}',
                color: Colors.orange,
              )),
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

  Widget _buildWithdrawForm(BuildContext context, WalletController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.teal.withValues(alpha: 0.1),
            Colors.indigo.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.money_off_outlined, color: Colors.teal, size: 20),
              SizedBox(width: 8),
              Text('Request Withdrawal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          _buildWithdrawMethodSelector(controller),
          const SizedBox(height: 16),
          TextField(
            controller: controller.withdrawAmountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Amount',
              prefixIcon: const Icon(Icons.diamond_outlined, color: Colors.teal),
              hintText: 'Enter diamonds or INR amount',
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
          const SizedBox(height: 12),
          TextField(
            controller: controller.accountDetailsController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Account Details (UPI / Bank)',
              prefixIcon: const Icon(Icons.account_balance_outlined, color: Colors.teal),
              hintText: 'Enter UPI ID or bank details',
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
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: Obx(() => ElevatedButton(
                  onPressed: controller.isProcessingWithdraw.value
                      ? null
                      : () async => await controller.processWithdraw(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: controller.isProcessingWithdraw.value
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Submit Withdrawal', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawMethodSelector(WalletController controller) {
    return Obx(() {
      final isDiamond = controller.selectedWithdrawMethod.value == 'diamonds';
      return Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => controller.selectedWithdrawMethod.value = 'diamonds',
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isDiamond ? Colors.cyan.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDiamond ? Colors.cyan : Colors.white.withValues(alpha: 0.15)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.diamond_outlined, color: Colors.cyan, size: 18),
                    const SizedBox(width: 6),
                    Text('Via Diamonds', style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: isDiamond ? Colors.cyan : Colors.white70,
                    )),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => controller.selectedWithdrawMethod.value = 'inr',
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: !isDiamond ? Colors.green.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: !isDiamond ? Colors.green : Colors.white.withValues(alpha: 0.15)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.money_outlined, color: Colors.green, size: 18),
                    const SizedBox(width: 6),
                    Text('Via INR', style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: !isDiamond ? Colors.green : Colors.white70,
                    )),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildWithdrawalInfo(WalletController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber.withValues(alpha: 0.8), size: 18),
              const SizedBox(width: 8),
              Text('Withdrawal Info', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.amber.withValues(alpha: 0.9))),
            ],
          ),
          const SizedBox(height: 10),
          _buildInfoRow('Min withdrawal', '₹${controller.minWithdrawal.value}'),
          _buildInfoRow('Tax deduction', '${controller.taxPercentage.value}%'),
          _buildInfoRow('Processing time', '24-48 hours'),
          _buildInfoRow('Exchange rate', '${controller.exchangeRate.value} coins = 1 diamond'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6))),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.8))),
        ],
      ),
    );
  }

  Widget _buildWithdrawalHistory(WalletController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Withdrawal History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        Obx(() {
          final withdrawals = <Map<String, dynamic>>[];
          if (withdrawals.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.history_outlined, size: 40, color: Colors.white.withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                    Text('No withdrawal history', style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.5))),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}
