// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/wallet/presentation/views/treasury_panel_screen.dart
// ARVIND PARTY - TREASURY MANAGEMENT PANEL
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/wallet_controller.dart';

class TreasuryPanelScreen extends StatelessWidget {
  const TreasuryPanelScreen({super.key});

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
          'Treasury Panel',
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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTreasuryOverview(controller),
              const SizedBox(height: 24),
              _buildCreditDebitSection(context, controller),
              const SizedBox(height: 24),
              _buildConfigSection(controller),
              const SizedBox(height: 24),
              _buildRecentOperations(controller),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTreasuryOverview(WalletController controller) {
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
                child: const Icon(Icons.admin_panel_settings_outlined, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Treasury Panel', style: TextStyle(fontSize: 14, color: Colors.white70)),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                          controller.formatCurrencyDouble(controller.treasuryBalance.value.toDouble()),
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreditDebitSection(BuildContext context, WalletController controller) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.withValues(alpha: 0.1),
            Colors.purple.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.swap_horiz_outlined, color: Colors.indigo, size: 20),
              SizedBox(width: 8),
              Text('Credit / Debit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Amount',
              prefixIcon: const Icon(Icons.attach_money_outlined, color: Colors.indigo),
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.indigo),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descriptionController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Description',
              prefixIcon: const Icon(Icons.description_outlined, color: Colors.indigo),
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.indigo),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final amount = double.tryParse(amountController.text);
                      final desc = descriptionController.text;
                      if (amount == null || amount <= 0 || desc.isEmpty) {
                        Get.snackbar('Error', 'Enter valid amount and description',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.withValues(alpha: 0.8),
                            colorText: Colors.white);
                        return;
                      }
                      await controller.creditTreasury(amount, desc);
                      amountController.clear();
                      descriptionController.clear();
                    },
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: const Text('Credit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final amount = double.tryParse(amountController.text);
                      final desc = descriptionController.text;
                      if (amount == null || amount <= 0 || desc.isEmpty) {
                        Get.snackbar('Error', 'Enter valid amount and description',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.withValues(alpha: 0.8),
                            colorText: Colors.white);
                        return;
                      }
                      await controller.debitTreasury(amount, desc);
                      amountController.clear();
                      descriptionController.clear();
                    },
                    icon: const Icon(Icons.remove_circle_outline, size: 18),
                    label: const Text('Debit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfigSection(WalletController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.settings_outlined, color: Colors.indigo, size: 20),
              SizedBox(width: 8),
              Text('Configuration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => _buildConfigRow('Exchange Rate', '${controller.exchangeRate.value} coins/diamond', Colors.cyan)),
          Obx(() => _buildConfigRow('Coin Buy Rate', '₹${controller.coinBuyRate.value.toStringAsFixed(2)}/coin', Colors.orange)),
          Obx(() => _buildConfigRow('Min Withdrawal', '₹${controller.minWithdrawal.value}', Colors.green)),
          Obx(() => _buildConfigRow('Tax Percentage', '${controller.taxPercentage.value}%', Colors.purple)),
        ],
      ),
    );
  }

  Widget _buildConfigRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOperations(WalletController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Operations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
                    Icon(Icons.history_outlined, size: 40, color: Colors.white.withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                    Text('No operations yet', style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.5))),
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
              final desc = tx['description'] ?? 'Operation';
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      amount >= 0 ? Icons.add_circle_outline : Icons.remove_circle_outline,
                      color: amount >= 0 ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(desc, style: const TextStyle(fontSize: 13, color: Colors.white)),
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
}
