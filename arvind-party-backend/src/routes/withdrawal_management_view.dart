import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/withdrawal_controller.dart';

class WithdrawalManagementView extends StatefulWidget {
  const WithdrawalManagementView({super.key});

  @override
  State<WithdrawalManagementView> createState() =>
      _WithdrawalManagementViewState();
}

class _WithdrawalManagementViewState extends State<WithdrawalManagementView> {
  late final WithdrawalController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(WithdrawalController());
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Cash-Out & Withdrawals',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                ElevatedButton.icon(
                  onPressed: () => controller.loadWithdrawals(),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text('Refresh',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF15141F),
                      side: const BorderSide(color: Color(0xFFFF8906))),
                )
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value)
                  return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFFFF8906)));
                if (controller.withdrawals.isEmpty)
                  return const Center(
                      child: Text('No cash-out requests found.',
                          style: TextStyle(color: Colors.white54)));

                return SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12)),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(Colors.black38),
                      columns: const [
                        DataColumn(
                            label: Text('User Profile',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF8906)))),
                        DataColumn(
                            label: Text('Amount & Coins',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF8906)))),
                        DataColumn(
                            label: Text('Payment Details',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF8906)))),
                        DataColumn(
                            label: Text('Status',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF8906)))),
                        DataColumn(
                            label: Text('Action',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF8906)))),
                      ],
                      rows: controller.withdrawals.map((req) {
                        final isPending = req['status'] == 'PENDING';
                        return DataRow(cells: [
                          DataCell(Text(req['userId']?['name'] ?? 'Unknown',
                              style: const TextStyle(color: Colors.white))),
                          DataCell(Text(
                              '\$${req['amountUSD']} (🪙 ${req['coinsDeducted']})',
                              style: const TextStyle(
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.bold))),
                          DataCell(Text(req['paymentDetails'] ?? 'N/A',
                              style: const TextStyle(color: Colors.white70))),
                          DataCell(Text(req['status'],
                              style: TextStyle(
                                  color: req['status'] == 'APPROVED'
                                      ? Colors.green
                                      : (req['status'] == 'REJECTED'
                                          ? Colors.red
                                          : Colors.orange)))),
                          DataCell(isPending
                              ? Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check_circle,
                                          color: Colors.green),
                                      onPressed: () =>
                                          controller.processRequest(
                                              req['_id'], 'APPROVED'),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.cancel,
                                          color: Colors.red),
                                      onPressed: () =>
                                          controller.processRequest(
                                              req['_id'], 'REJECTED'),
                                    ),
                                  ],
                                )
                              : const Text('PROCESSED',
                                  style: TextStyle(
                                      color: Colors.white54, fontSize: 12))),
                        ]);
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
