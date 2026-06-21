// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/agency/presentation/views/agency_salary_screen.dart
// ARVIND PARTY - AGENCY COMMISSION TRACKER & SALARY MANAGEMENT
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/agency_controller.dart';

class AgencySalaryScreen extends StatelessWidget {
  const AgencySalaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AgencyController controller = Get.find<AgencyController>();

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
          'Commission & Salary',
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
                _buildRevenueOverviewCard(controller),
                const SizedBox(height: 24),
                _buildCommissionBreakdownSection(controller),
                const SizedBox(height: 24),
                _buildMemberEarningsSection(controller),
                const SizedBox(height: 24),
                _buildCalculationInfoCard(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueOverviewCard(AgencyController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.2),
            Colors.deepOrange.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.35),
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
                    colors: [Colors.orange, Colors.deepOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_outlined,
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
                      'Total Agency Revenue',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Obx(() => Text(
                          '₹${(156250.75).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 26,
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
                child: _buildOverviewStat(
                  icon: Icons.payments_outlined,
                  label: 'Host Earnings',
                  value: '₹${(93750.45).toStringAsFixed(2)}',
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: _buildOverviewStat(
                  icon: Icons.how_to_reg_outlined,
                  label: 'Agent Earnings',
                  value: '₹${(46875.22).toStringAsFixed(2)}',
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildOverviewStat(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Agency Balance',
                  value: '₹${(15625.08).toStringAsFixed(2)}',
                  color: Colors.orange,
                ),
              ),
              Expanded(
                child: _buildOverviewStat(
                  icon: Icons.trending_up_outlined,
                  label: 'Pending Payouts',
                  value: '₹${(12500.00).toStringAsFixed(2)}',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStat({
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
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionBreakdownSection(AgencyController controller) {
    final commissionData = [
      {
        'type': 'Room Revenue',
        'amount': 87500.00,
        'percentage': 60,
        'color': Colors.blue,
        'icon': Icons.voice_chat_outlined,
      },
      {
        'type': 'Gift Sales',
        'amount': 45000.00,
        'percentage': 25,
        'color': Colors.pink,
        'icon': Icons.card_giftcard_outlined,
      },
      {
        'type': 'Event Fees',
        'amount': 18750.00,
        'percentage': 10,
        'color': Colors.purple,
        'icon': Icons.event_outlined,
      },
      {
        'type': 'Other',
        'amount': 9000.75,
        'percentage': 5,
        'color': Colors.green,
        'icon': Icons.more_horiz,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Revenue Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: Icon(
                Icons.bar_chart_outlined,
                size: 14,
                color: Colors.orange.withValues(alpha: 0.8),
              ),
              label: Text(
                'Details',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: commissionData.length,
          itemBuilder: (context, index) {
            final data = commissionData[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (data['color'] as Color).withValues(alpha: 0.12),
                    (data['color'] as Color).withValues(alpha: 0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (data['color'] as Color).withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (data['color'] as Color).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      data['icon'] as IconData,
                      color: data['color'] as Color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['type'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${data['percentage']}% of total',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${(data['amount'] as double).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: data['color'] as Color,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 60,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          widthFactor: (data['percentage'] as int) / 100,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              color: (data['color'] as Color).withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMemberEarningsSection(AgencyController controller) {
    final members = [
      {
        'name': 'Arvind (Host)',
        'role': 'Host',
        'revenue': 25000.00,
        'commission': '60%',
        'payout': 15000.00,
        'status': 'paid',
        'icon': Icons.mic_outlined,
        'color': Colors.blue,
      },
      {
        'name': 'Priya (Agent)',
        'role': 'Agent',
        'revenue': 18000.00,
        'commission': '25%',
        'payout': 4500.00,
        'status': 'pending',
        'icon': Icons.person_outlined,
        'color': Colors.green,
      },
      {
        'name': 'Rahul (Host)',
        'role': 'Host',
        'revenue': 35000.00,
        'commission': '60%',
        'payout': 21000.00,
        'status': 'paid',
        'icon': Icons.mic_outlined,
        'color': Colors.blue,
      },
      {
        'name': 'Sneha (Agent)',
        'role': 'Agent',
        'revenue': 22000.00,
        'commission': '25%',
        'payout': 5500.00,
        'status': 'pending',
        'icon': Icons.person_outlined,
        'color': Colors.green,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Member Earnings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: Icon(
                Icons.arrow_downward,
                size: 14,
                color: Colors.green.withValues(alpha: 0.8),
              ),
              label: Text(
                'Payout All',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            final isPaid = member['status'] == 'paid';

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
                          color: (member['color'] as Color).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          member['icon'] as IconData,
                          color: member['color'] as Color,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member['name'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${member['commission']} commission',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPaid
                              ? Colors.green.withValues(alpha: 0.15)
                              : Colors.orange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isPaid ? 'Paid' : 'Pending',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isPaid ? Colors.green : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Revenue',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${(member['revenue'] as double).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Payout Amount',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${(member['payout'] as double).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: isPaid
                            ? null
                            : () {
                                Get.snackbar(
                                  'Payout Initiated',
                                  'Transferring ₹${(member['payout'] as double).toStringAsFixed(2)} to ${member['name']}',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green.withValues(alpha: 0.8),
                                  colorText: Colors.white,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPaid ? Colors.grey : Colors.green,
                          minimumSize: const Size(70, 32),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          isPaid ? 'Done' : 'Pay',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCalculationInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Commission Logic',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hosts receive 60% of generated revenue. Agents receive 25% from referred host earnings. Agency retains 15% for operations.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}