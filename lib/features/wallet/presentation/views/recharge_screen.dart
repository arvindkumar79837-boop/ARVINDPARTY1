// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/wallet/presentation/views/recharge_screen.dart
// ARVIND PARTY - RECHARGE SCREEN (Buy Coins via Razorpay)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/wallet_controller.dart';
import '../../../core/services/google_play_billing_service.dart';

class RechargeScreen extends StatelessWidget {
  const RechargeScreen({super.key});

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
          'Recharge',
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
                _buildCurrentBalanceCard(controller),
                const SizedBox(height: 24),
                _buildQuickAmounts(controller),
                const SizedBox(height: 24),
                _buildPackagesList(controller),
                const SizedBox(height: 24),
                _buildPaymentMethodInfo(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentBalanceCard(WalletController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
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
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current Balance', style: TextStyle(fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 4),
                Obx(() => Text(
                      '${controller.formatCurrency(controller.coinBalance.value)} coins',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Obx(() => Text(
                  '₹${controller.coinBuyRate.value.toStringAsFixed(0)}/coin',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmounts(WalletController controller) {
    final amounts = [100, 200, 500, 1000, 2000, 5000];
    final selectedAmount = 0.obs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Select', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text('Tap an amount to recharge', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.5))),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: amounts.map((amount) {
            final coins = (amount / controller.coinBuyRate.value).round();
            return Obx(() {
              final isSelected = selectedAmount.value == amount;
              return GestureDetector(
                onTap: () {
                  selectedAmount.value = amount;
                  final pkg = controller.packages.isNotEmpty
                      ? controller.packages.firstWhereOrNull((p) => p.price.round() == amount)
                      : null;
                  if (pkg != null) {
                    controller.selectedPackage.value = pkg;
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.green : Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text('₹$amount', style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.green : Colors.white,
                      )),
                      const SizedBox(height: 2),
                      Text('$coins coins', style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.green.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.5),
                      )),
                    ],
                  ),
                ),
              );
            });
          }).toList(),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (selectedAmount.value == 0) return const SizedBox.shrink();
          return SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: controller.isProcessingRecharge.value
                  ? null
                  : () async {
                      if (controller.selectedPackage.value == null) {
                        final pkg = controller.packages.firstWhereOrNull(
                          (p) => p.price.round() == selectedAmount.value,
                        );
                        if (pkg != null) controller.selectedPackage.value = pkg;
                      }
                      await controller.processRecharge();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              child: controller.isProcessingRecharge.value
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(
                      'Pay ₹${selectedAmount.value} via Google Play',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPackagesList(WalletController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('All Packages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.packages.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text('No packages available', style: TextStyle(color: Colors.white70))),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.packages.length,
            itemBuilder: (context, index) {
              final pkg = controller.packages[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withValues(alpha: 0.1),
                      Colors.teal.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.monetization_on, color: Colors.green, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(pkg.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                              if (pkg.isPopular) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('POPULAR', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.orange)),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('${pkg.coins} coins', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7))),
                        ],
                      ),
                    ),
                    Text('₹${pkg.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: controller.isProcessingRecharge.value
                          ? null
                          : () async {
                              controller.selectedPackage.value = pkg;
                              await controller.processRecharge();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Buy'),
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

  Widget _buildPaymentMethodInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.withValues(alpha: 0.7), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Payments are processed securely via Google Play Store. Coins are purchased as consumable items.',
              style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
            ),
          ),
        ],
      ),
    );
  }
}
