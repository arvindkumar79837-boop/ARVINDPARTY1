import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WithdrawalApprovalView extends StatefulWidget {
  const WithdrawalApprovalView({super.key});

  @override
  State<WithdrawalApprovalView> createState() => _WithdrawalApprovalViewState();
}

class _WithdrawalApprovalViewState extends State<WithdrawalApprovalView> {
  // यूआई डिबगिंग के लिए लाइव पेंडिंग विथड्रॉल रिक्वेस्ट्स की डमी लिस्ट
  final List<Map<String, dynamic>> pendingWithdrawals = [
    {
      'id': 'W-89301',
      'uid': '798372',
      'name': 'Riya Sharma (Host)',
      'diamonds': '50,000',
      'payoutAmount': '₹5,000',
      'targetStatus': 'Target Achieved ✔',
      'agency': 'Star Media Agency',
    },
    {
      'id': 'W-89302',
      'uid': '654321',
      'name': 'Rahul Verma (User)',
      'diamonds': '100,000',
      'payoutAmount': '₹10,000',
      'targetStatus': 'Target Achieved ✔',
      'agency': 'Independent',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF14141F), // सिग्नेचर डीप डार्क बैकग्राउंड
      body: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // हेडर टाइटल
                  const Text(
                    "Manual Withdrawal Settlements",
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Review completed host targets, verify cash calculations, and authorize manual out-of-app financial settlements.",
                    style: TextStyle(color: Color(0xA3FFFFFF), fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  // विथड्रॉल टेबल कार्ड
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2D2D44)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Pending Settlement Queues",
                          style: TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Divider(color: Color(0xFF2D2D44), height: 32),

                        if (pendingWithdrawals.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text("No pending withdrawal settlements found.", style: TextStyle(color: Colors.white30, fontSize: 16)),
                            ),
                          )
                        else
                          // डेटा टेबल (Data Table)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(const Color(0xFF14141F)),
                              dataRowHeight: 64,
                              columns: const [
                                DataColumn(label: Text("TXN ID", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))),
                                DataColumn(label: Text("USER UID", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                DataColumn(label: Text("NAME", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                DataColumn(label: Text("DIAMONDS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                DataColumn(label: Text("PAYOUT VALUE", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                                DataColumn(label: Text("TARGET AUDIT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                DataColumn(label: Text("ACTIONS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                              ],
                              rows: pendingWithdrawals.map((req) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(req['id'], style: const TextStyle(color: Colors.white54, fontFamily: 'monospace'))),
                                    DataCell(Text(req['uid'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                    DataCell(Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(req['name'], style: const TextStyle(color: Colors.white)),
                                        Text(req['agency'], style: const TextStyle(color: Colors.white30, fontSize: 11)),
                                      ],
                                    )),
                                    DataCell(Text(req['diamonds'], style: const TextStyle(color: Colors.amber, fontFamily: 'monospace'))),
                                    DataCell(Text(req['payoutAmount'], style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16))),
                                    DataCell(Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                      child: Text(req['targetStatus'], style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                                    )),
                                    DataCell(Row(
                                      children: [
                                        // अप्रूव बटन (मैन्युअल पेआउट कम्प्लीट मार्क करने के लिए)
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                          ),
                                          child: const Text("Mark Paid", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                          onPressed: () => _handleSettlement(req, true),
                                        ),
                                        const SizedBox(width: 8),
                                        // रिजेक्ट बटन
                                        OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: Colors.redAccent),
                                            foregroundColor: Colors.redAccent,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                          ),
                                          child: const Text("Reject", style: TextStyle(fontSize: 12)),
                                          onPressed: () => _handleSettlement(req, false),
                                        ),
                                      ],
                                    )),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  /// अप्रूवल और रिजेक्शन डायलॉग और लॉजिक हैंडलर
  void _handleSettlement(Map<String, dynamic> request, bool isApproved) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: Text(
          isApproved ? "Confirm Settlement Dispatch" : "Reject Withdrawal Request",
          style: TextStyle(color: isApproved ? Colors.green : Colors.redAccent, fontSize: 18),
        ),
        content: Text(
          isApproved
              ? "Are you sure you have manually transferred ${request['payoutAmount']} out-of-app to ${request['name']}? This action clears their diamond balance."
              : "Are you sure you want to reject TXN ${request['id']}? Diamonds will be refunded back to host wallet."
        ),
        actions: [
          TextButton(
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
            onPressed: () => Get.back(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isApproved ? Colors.green : Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: Text(isApproved ? "Confirm Paid" : "Confirm Reject"),
            onPressed: () {
              setState(() {
                pendingWithdrawals.removeWhere((element) => element['id'] == request['id']);
              });
              Get.back();
              Get.snackbar(
                isApproved ? "Settlement Recorded" : "Request Rejected",
                isApproved 
                  ? "TXN ${request['id']} successfully logged as completely settled by you."
                  : "TXN ${request['id']} has been denied and diamonds rolled back.",
                backgroundColor: isApproved ? Colors.green : Colors.redAccent,
                colorText: Colors.white,
                maxWidth: 450,
              );
            },
          ),
        ],
      ),
    );
  }
}