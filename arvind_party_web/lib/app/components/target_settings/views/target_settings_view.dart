import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TargetSettingsView extends StatefulWidget {
  const TargetSettingsView({super.key});

  @override
  State<TargetSettingsView> createState() => _TargetSettingsViewState();
}

class _TargetSettingsViewState extends State<TargetSettingsView> {
  // टेक्स्ट फ़ील्ड्स और सेटिंग्स कंट्रोल करने के लिए
  final TextEditingController exchangeCutController = TextEditingController(text: "50"); // डिफ़ॉल्ट 50% कटिंग
  final TextEditingController minExchangeDiamondsController = TextEditingController(text: "10000");
  final TextEditingController agencyBonusController = TextEditingController(text: "10"); // एजेंसी को 10% बोनस

  String targetCycle = 'Monthly'; // डिफ़ॉल्ट रूप से मंथली साइकिल
  bool autoResetLeaderboard = true;

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
                    "Target & Exchange Configurations",
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Configure platform-wide host target timelines, earning structures, and automated diamond cutting percentages.",
                    style: TextStyle(color: Color(0xA3FFFFFF), fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // बाएँ हाथ पर: टारगेट साइकिल और ऑटोमेशन सेटिंग्स
                      Expanded(
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
                              const Row(
                                children: [
                                  Icon(Icons.update, color: Colors.orange, size: 24),
                                  SizedBox(width: 8),
                                  Text("Automated Target Cycle", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const Divider(color: Color(0xFF2D2D44), height: 32),

                              const Text(
                                "Target Timeline Frame",
                                style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF14141F),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF3D3D5C)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: targetCycle,
                                    dropdownColor: const Color(0xFF1E1E2E),
                                    isExpanded: true,
                                    icon: const Icon(Icons.arrow_drop_down, color: Colors.orange),
                                    items: ['Weekly', '15 Days', 'Monthly'].map((String cycle) {
                                      return DropdownMenuItem<String>(
                                        value: cycle,
                                        child: Text(cycle, style: const TextStyle(color: Colors.white)),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        targetCycle = value!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              SwitchListTile(
                                title: const Text(
                                  "Auto-Reset Leaderboards & Targets",
                                  style: TextStyle(color: Color(0xE6FFFFFF), fontSize: 14),
                                ),
                                subtitle: const Text(
                                  "Wipes rankings and logs fresh targets at the end of the selected cycle via backend Cron Job.",
                                  style: TextStyle(color: Colors.white54, fontSize: 11),
                                ),
                                value: autoResetLeaderboard,
                                activeThumbColor: Colors.orange,
                                contentPadding: EdgeInsets.zero,
                                onChanged: (val) => setState(() => autoResetLeaderboard = val),
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
                                  icon: const Icon(Icons.save_rounded),
                                  label: const Text("Save Schedule Configurations", style: TextStyle(fontWeight: FontWeight.bold)),
                                  onPressed: () {
                                    Get.snackbar(
                                      "Scheduler Updated",
                                      "Platform clock successfully synchronized to a $targetCycle target sequence.",
                                      backgroundColor: Colors.green,
                                      colorText: Colors.white,
                                      maxWidth: 450,
                                    );
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),

                      // दाएँ हाथ पर: डायमंड एक्सचेंज और एडमिन कमीशन सेटिंग्स (Cutting Console)
                      Expanded(
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
                              const Row(
                                children: [
                                  Icon(Icons.currency_exchange, color: Colors.green, size: 24),
                                  SizedBox(width: 8),
                                  Text("Diamond Cutting & Revenue Share", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const Divider(color: Color(0xFF2D2D44), height: 32),

                              _buildTextField(
                                label: "Platform Exchange Cut (%)",
                                hint: "e.g., 50 for a clean 50-50 ratio split",
                                controller: exchangeCutController,
                                icon: Icons.percent,
                              ),
                              const SizedBox(height: 20),

                              _buildTextField(
                                label: "Minimum Diamond Threshold to Exchange",
                                hint: "e.g., 10000 diamonds required",
                                controller: minExchangeDiamondsController,
                                icon: Icons.gavel,
                              ),
                              const SizedBox(height: 20),

                              _buildTextField(
                                label: "Agency Commission Top-up (%)",
                                hint: "Bonus share transferred to Agency wallet",
                                controller: agencyBonusController,
                                icon: Icons.card_membership,
                              ),
                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text("Deploy Revenue Ratios", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  onPressed: () {
                                    if (exchangeCutController.text.isEmpty) return;
                                    
                                    Get.dialog(
                                      AlertDialog(
                                        backgroundColor: const Color(0xFF1E1E2E),
                                        title: const Row(
                                          children: [
                                            Icon(Icons.security, color: Colors.green),
                                            SizedBox(width: 8),
                                            Text("Ratios Enforced Live", style: TextStyle(color: Colors.white, fontSize: 18)),
                                          ],
                                        ),
                                        content: Text(
                                          "Platform cutting successfully locked at ${exchangeCutController.text}%. Every host exchange action will now automatically route ${exchangeCutController.text}% to the owner registry."
                                        ),
                                        actions: [
                                          TextButton(
                                            child: const Text("Confirm", style: TextStyle(color: Colors.orange)),
                                            onPressed: () => Get.back(),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
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

  // टेक्स्ट फ़ील्ड बनाने का हेल्पर विजेट
  Widget _buildTextField({required String label, required String hint, required TextEditingController controller, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.orange, size: 18),
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0x4DFFFFFF), fontSize: 13),
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