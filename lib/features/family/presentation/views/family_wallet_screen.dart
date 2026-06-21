// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/family/presentation/views/family_wallet_screen.dart
// ARVIND PARTY - FAMILY WALLET VIEW (Shared treasury, deposits, allocation)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/family_controller.dart';

class FamilyWalletScreen extends StatelessWidget {
  const FamilyWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FamilyController controller = Get.find<FamilyController>();

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
          'Family Wallet',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {},
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTreasuryBalanceCard(controller),
                const SizedBox(height: 24),
                _buildQuickActionsCard(controller),
                const SizedBox(height: 24),
                _buildContributionLogsSection(),
                const SizedBox(height: 24),
                _buildResourceAllocationSection(controller),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTreasuryBalanceCard(FamilyController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.withValues(alpha: 0.25),
            Colors.indigo.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.deepPurple.withValues(alpha: 0.35),
          width: 1.5,
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
                    colors: [Colors.deepPurple, Colors.indigo],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
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
                      'Family Treasury',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                          '${(42500.50).toStringAsFixed(2)} 🪙',
                          style: const TextStyle(
                            fontSize: 28,
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
                  icon: Icons.savings_outlined,
                  label: 'Total Contributions',
                  value: '12,450 🪙',
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: _buildMiniStat(
                  icon: Icons.payments_outlined,
                  label: 'Total Withdrawals',
                  value: '7,200 🪙',
                  color: Colors.red,
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
        color: Colors.white.withValues(alpha: 0.05),
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
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard(FamilyController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.arrow_upward_outlined,
                color: Colors.green,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Treasury Operations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.add_circle_outlined,
                  label: 'Contribute',
                  color: Colors.green,
                  onTap: () => _showContributeDialog(controller),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.remove_circle_outlined,
                  label: 'Withdraw',
                  color: Colors.red,
                  onTap: () => _showWithdrawDialog(controller),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.swap_horiz_outlined,
                  label: 'Transfer',
                  color: Colors.blue,
                  onTap: () => _showTransferDialog(controller),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.history_outlined,
                  label: 'History',
                  color: Colors.orange,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContributionLogsSection() {
    final logs = [
      {
        'type': 'contribution',
        'user': 'Arvind',
        'amount': 500.0,
        'time': DateTime.now().subtract(const Duration(minutes: 5)),
        'note': 'Daily contribution',
      },
      {
        'type': 'withdrawal',
        'user': 'Priya',
        'amount': 200.0,
        'time': DateTime.now().subtract(const Duration(hours: 2)),
        'note': 'Gift purchase',
      },
      {
        'type': 'contribution',
        'user': 'Rahul',
        'amount': 1000.0,
        'time': DateTime.now().subtract(const Duration(hours: 5)),
        'note': 'Event reward',
      },
      {
        'type': 'transfer',
        'user': 'Admin',
        'amount': 300.0,
        'time': DateTime.now().subtract(const Duration(days: 1)),
        'note': 'Transferred to sub-family',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Contribution Logs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: Icon(
                Icons.filter_list_outlined,
                size: 14,
                color: Colors.deepPurple.withValues(alpha: 0.8),
              ),
              label: Text(
                'Filter',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.deepPurple.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            final type = log['type'] as String;
            final isPositive = type == 'contribution';

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isPositive
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isPositive
                          ? Icons.arrow_downward_outlined
                          : Icons.arrow_upward_outlined,
                      color: isPositive ? Colors.green : Colors.red,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log['note'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${log['user']} • ${_timeAgo(log['time'] as DateTime)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${isPositive ? '+' : '-'}${log['amount']} 🪙',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
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

  Widget _buildResourceAllocationSection(FamilyController controller) {
    final roles = [
      {
        'role': 'Owner',
        'allocation': 40,
        'icon': Icons.admin_panel_settings_outlined,
        'color': Colors.red,
        'permissions': ['Withdraw', 'Manage', 'Allocate'],
      },
      {
        'role': 'Co-Leader',
        'allocation': 30,
        'icon': Icons.shield_outlined,
        'color': Colors.orange,
        'permissions': ['Withdraw', 'Manage'],
      },
      {
        'role': 'Member',
        'allocation': 20,
        'icon': Icons.person_outlined,
        'color': Colors.blue,
        'permissions': ['Contribute'],
      },
      {
        'role': 'Beginner',
        'allocation': 10,
        'icon': Icons.star_outlined,
        'color': Colors.grey,
        'permissions': ['View'],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Resource Allocation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: Icon(
                Icons.settings_outlined,
                size: 14,
                color: Colors.deepPurple.withValues(alpha: 0.8),
              ),
              label: Text(
                'Manage',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.deepPurple.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: roles.length,
          itemBuilder: (context, index) {
            final role = roles[index];
            final allocation = role['allocation'] as int;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: (role['color'] as Color).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          role['icon'] as IconData,
                          color: role['color'] as Color,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              role['role'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Wrap(
                              spacing: 6,
                              children: (role['permissions'] as List<String>)
                                  .map(
                                    (p) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        p,
                                        style: const TextStyle(
                                          fontSize: 9,
                                          color: Colors.deepPurple,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$allocation%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: allocation / 100,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              role['color'] as Color,
                              (role['color'] as Color).withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
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

  void _showContributeDialog(FamilyController controller) {
    var amountController = TextEditingController();
    var noteController = TextEditingController();
    var isProcessing = false.obs;

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text(
          'Contribute to Family Treasury',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Amount (🪙)',
                  prefixIcon: const Icon(Icons.monetization_on_outlined, color: Colors.orange),
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
              TextField(
                controller: noteController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Note (optional)',
                  hintText: 'e.g., Daily contribution',
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          Obx(() => ElevatedButton(
                onPressed: isProcessing.value ? null : () async {
                  final amount = double.tryParse(amountController.text);
                  if (amount == null || amount <= 0) {
                    Get.snackbar(
                      'Error',
                      'Please enter a valid amount',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.withValues(alpha: 0.8),
                      colorText: Colors.white,
                    );
                    return;
                  }

                  isProcessing.value = true;
                  await Future.delayed(const Duration(milliseconds: 800));
                  Get.back();
                  Get.snackbar(
                    'Success',
                    'Contributed $amount 🪙 to family treasury',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.withValues(alpha: 0.8),
                    colorText: Colors.white,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: isProcessing.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Contribute',
                        style: TextStyle(color: Colors.white),
                      ),
              )),
        ],
      ),
    );
  }

  void _showWithdrawDialog(FamilyController controller) {
    var amountController = TextEditingController();
    var reasonController = TextEditingController();
    var isProcessing = false.obs;

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text(
          'Withdraw from Treasury',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Amount (🪙)',
                  prefixIcon: const Icon(Icons.monetization_on_outlined, color: Colors.red),
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Reason',
                  hintText: 'e.g., Gift purchase, Event fee',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          Obx(() => ElevatedButton(
                onPressed: isProcessing.value ? null : () async {
                  final amount = double.tryParse(amountController.text);
                  if (amount == null || amount <= 0) {
                    Get.snackbar(
                      'Error',
                      'Please enter a valid amount',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.withValues(alpha: 0.8),
                      colorText: Colors.white,
                    );
                    return;
                  }

                  isProcessing.value = true;
                  await Future.delayed(const Duration(milliseconds: 800));
                  Get.back();
                  Get.snackbar(
                    'Success',
                    'Withdrawn $amount 🪙 from treasury',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.withValues(alpha: 0.8),
                    colorText: Colors.white,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: isProcessing.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Withdraw',
                        style: TextStyle(color: Colors.white),
                      ),
              )),
        ],
      ),
    );
  }

  void _showTransferDialog(FamilyController controller) {
    Get.snackbar(
      'Transfer',
      'Transfer family funds to another family',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.deepPurple.withValues(alpha: 0.8),
      colorText: Colors.white,
    );
  }

  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}