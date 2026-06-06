import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/withdrawal_admin_controller.dart';

class WithdrawalManagementView extends StatefulWidget {
  const WithdrawalManagementView({super.key});

  @override
  State<WithdrawalManagementView> createState() =>
      _WithdrawalManagementViewState();
}

class _WithdrawalManagementViewState extends State<WithdrawalManagementView> {
  late final WithdrawalAdminController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(WithdrawalAdminController());
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.redAccent;
      case 'pending':
      default:
        return Colors.orangeAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Withdrawal Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => controller.loadWithdrawals(),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text('Refresh',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF15141F),
                    side: const BorderSide(color: Color(0xFFFF8906)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Review pending payouts and manage completed transactions.',
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 24),

            // DATA TABLE
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFFFF8906)));
                }

                if (controller.withdrawals.isEmpty) {
                  return const Center(
                      child: Text('No withdrawal requests found.',
                          style: TextStyle(color: Colors.white54)));
                }

                return SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(Colors.black38),
                      dataRowMinHeight: 60,
                      dataRowMaxHeight: 60,
                      columns: const [
                        DataColumn(
                            label: Text('User Details',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF8906)))),
                        DataColumn(
                            label: Text('Amount',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF8906)))),
                        DataColumn(
                            label: Text('Payment Info',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF8906)))),
                        DataColumn(
                            label: Text('Status',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF8906)))),
                        DataColumn(
                            label: Text('Actions',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF8906)))),
                      ],
                      rows: controller.withdrawals.map((item) {
                        final id = item['_id'] ?? item['id'];
                        final user = item['userId'] ?? {};
                        final status = item['status'] ?? 'pending';
                        final isPending = status == 'pending';

                        return DataRow(
                          cells: [
                            // USER DETAILS
                            DataCell(
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        user['avatar'] ??
                                            'https://via.placeholder.com/150'),
                                    radius: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(user['name'] ?? 'Unknown User',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            // AMOUNT
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      '\$${item['amountUSD']?.toStringAsFixed(2) ?? '0.00'}',
                                      style: const TextStyle(
                                          color: Colors.greenAccent,
                                          fontWeight: FontWeight.bold)),
                                  Text('🪙 ${item['coinsDeducted'] ?? 0}',
                                      style: const TextStyle(
                                          color: Colors.white54, fontSize: 12)),
                                ],
                              ),
                            ),
                            // PAYMENT INFO
                            DataCell(Text(item['paymentDetails'] ?? 'N/A',
                                style: const TextStyle(color: Colors.white70))),
                            // STATUS
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      _getStatusColor(status).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                      color: _getStatusColor(status),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            // ACTIONS
                            DataCell(
                              isPending
                                  ? Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.check_circle,
                                              color: Colors.green),
                                          onPressed: () => controller
                                              .updateStatus(id, 'approved'),
                                          tooltip: 'Approve',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.cancel,
                                              color: Colors.redAccent),
                                          onPressed: () => controller
                                              .updateStatus(id, 'rejected'),
                                          tooltip: 'Reject & Refund',
                                        ),
                                      ],
                                    )
                                  : const Text('--',
                                      style: TextStyle(color: Colors.white54)),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
