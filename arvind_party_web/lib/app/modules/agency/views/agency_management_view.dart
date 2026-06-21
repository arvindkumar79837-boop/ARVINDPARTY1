import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AgencyManagementView extends StatefulWidget {
  const AgencyManagementView({Key? key}) : super(key: key);

  @override
  State<AgencyManagementView> createState() => _AgencyManagementViewState();
}

class _AgencyManagementViewState extends State<AgencyManagementView> {
  final TextEditingController ownerUidController = TextEditingController();
  final TextEditingController agencyNameController = TextEditingController();
  final TextEditingController commissionController = TextEditingController(text: "10"); // डिफ़ॉल्ट 10%

  // डमी डेटा: ऐप में चल रही एक्टिव एजेंसीज की लिस्ट
  final List<Map<String, dynamic>> activeAgencies = [
    {
      'id': 'AGN-7701',
      'name': 'Star Media Agency',
      'ownerUid': '654321',
      'commission': '12%',
      'totalHosts': '15',
      'status': 'Active'
    },
    {
      'id': 'AGN-7702',
      'name': 'Arvind Royal Club',
      'ownerUid': '987654',
      'commission': '10%',
      'totalHosts': '32',
      'status': 'Active'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF14141F), // सिग्नेचर डीप डार्क थीम
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
                    "Agency Management & Commission Center",
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Register new host agencies, configure custom commission payouts, and monitor global network scaling.",
                    style: TextStyle(color: Color(0xA3FFFFFF), fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // बाएँ हाथ पर: नई एजेंसी बनाने का फॉर्म
                      Expanded(
                        flex: 3,
                        child: Container(
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
                                "Register New Official Agency",
                                style: TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const Divider(color: Color(0xFF2D2D44), height: 32),

                              _buildTextField(
                                label: "Agency Boss / Owner UID",
                                hint: "Enter user UID who will manage this agency",
                                controller: ownerUidController,
                                icon: Icons.person_pin,
                              ),
                              const SizedBox(height: 20),

                              _buildTextField(
                                label: "Official Agency Name",
                                hint: "e.g., Nexus Talent Agency",
                                controller: agencyNameController,
                                icon: Icons.business,
                              ),
                              const SizedBox(height: 20),

                              _buildTextField(
                                label: "Agency Commission Share (%)",
                                hint: "e.g., 10 means 10% bonus from host targets",
                                controller: commissionController,
                                icon: Icons.monetization_on,
                              ),
                              const SizedBox(height: 32),

                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  icon: const Icon(Icons.add_business_rounded),
                                  label: const Text("Create and Activate Agency Profile", style: TextStyle(fontWeight: FontWeight.bold)),
                                  onPressed: () {
                                    if (ownerUidController.text.isEmpty || agencyNameController.text.isEmpty) {
                                      Get.snackbar("Error", "Owner UID and Agency Name are required fields.",
                                          backgroundColor: Colors.redAccent, colorText: Colors.white, maxWidth: 450);
                                      return;
                                    }

                                    setState(() {
                                      activeAgencies.add({
                                        'id': "AGN-${activeAgencies.length + 7703}",
                                        'name': agencyNameController.text,
                                        'ownerUid': ownerUidController.text,
                                        'commission': "${commissionController.text}%",
                                        'totalHosts': '0',
                                        'status': 'Active'
                                      });
                                    });

                                    Get.snackbar("Agency Created", "'${agencyNameController.text}' has been officially synchronized into app network.",
                                        backgroundColor: Colors.green, colorText: Colors.white, maxWidth: 450);

                                    ownerUidController.clear();
                                    agencyNameController.clear();
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),

                      // दाएँ हाथ पर: चल रही एक्टिव एजेंसीज की लिस्ट
                      Expanded(
                        flex: 4,
                        child: Container(
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
                                "Live Platform Agencies",
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const Divider(color: Color(0xFF2D2D44), height: 32),

                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: activeAgencies.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final agency = activeAgencies[index];
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF14141F),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFF2D2D44)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(agency['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                            const SizedBox(height: 6),
                                            Text("ID: ${agency['id']}  |  Boss UID: ${agency['ownerUid']}", style: const TextStyle(color: Colors.white30, fontSize: 12)),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text("Share: ${agency['commission']}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)),
                                            const SizedBox(height: 4),
                                            Text("Hosts: ${agency['totalHosts']}", style: const TextStyle(color: Colors.white54, fontSize: 11)),
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField({required String label, required String hint, required TextEditingController controller, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.orange, size: 18),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFF14141F),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF3D3D5C))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.orange)),
          ),
        ),
      ],
    );
  }
}