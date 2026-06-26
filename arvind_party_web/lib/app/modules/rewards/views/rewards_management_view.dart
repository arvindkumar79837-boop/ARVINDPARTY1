import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RewardsManagementView extends StatefulWidget {
  const RewardsManagementView({super.key});

  @override
  State<RewardsManagementView> createState() => _RewardsManagementViewState();
}

class _RewardsManagementViewState extends State<RewardsManagementView> {
  final TextEditingController userUidController = TextEditingController();
  final TextEditingController durationController = TextEditingController(text: "7"); // डिफ़ॉल्ट 7 दिन के लिए फ्रेम

  String assetType = 'VIP Frame'; // डिफ़ॉल्ट एसेट टाइप
  String? selectedAsset;

  // प्लेटफॉर्म के प्रीमियम एसेट्स की लिस्ट (जो स्टोर में भी बिकेंगे)
  final List<String> availableFrames = [
    'Arvind Party Lord Crown (Frame)',
    'Neon Blue Fire Ring (Frame)',
    'Golden Dragon Legend (Entry Effect)',
    'Supercar Fly-In Sound (Entry Effect)',
    'VVIP Royal Badge (Avatar Ribbon)'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF14141F), // डीप डार्क थीम
      body: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // हेडर एरिया
                  const Text(
                    "VIP Assets & Frame Injector",
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Directly inject premium avatar frames, chat bubbles, and room entry animations onto any user profile via UID.",
                    style: TextStyle(color: Color(0xA3FFFFFF), fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  // मेन फॉर्म बॉक्स
                  Container(
                    constraints: const BoxConstraints(maxWidth: 700),
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
                          "Direct Asset Credit Box",
                          style: TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Divider(color: Color(0xFF2D2D44), height: 32),

                        // यूजर UID इनपुट
                        _buildTextField(
                          label: "Target User UID",
                          hint: "Enter user unique ID (e.g., 798372)",
                          controller: userUidController,
                          icon: Icons.account_box,
                        ),
                        const SizedBox(height: 20),

                        // एसेट टाइप और ड्यूरेशन रो
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Asset Category", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
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
                                        value: assetType,
                                        dropdownColor: const Color(0xFF1E1E2E),
                                        isExpanded: true,
                                        icon: const Icon(Icons.arrow_drop_down, color: Colors.orange),
                                        items: ['VIP Frame', 'Entry Effect', 'Badge'].map((String type) {
                                          return DropdownMenuItem<String>(
                                            value: type,
                                            child: Text(type, style: const TextStyle(color: Colors.white)),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            assetType = value!;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildTextField(
                                label: "Validity Duration (In Days)",
                                hint: "e.g., 7, 30, or 9999 for Permanent",
                                controller: durationController,
                                icon: Icons.av_timer,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // स्पेसिफिक एसेट सेलेक्ट ड्रॉपडाउन
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Select Specific Reward Item", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
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
                                  value: selectedAsset,
                                  hint: const Text("Choose item from global asset inventory...", style: TextStyle(color: Colors.white30, fontSize: 13)),
                                  dropdownColor: const Color(0xFF1E1E2E),
                                  isExpanded: true,
                                  icon: const Icon(Icons.arrow_drop_down, color: Colors.orange),
                                  items: availableFrames.map((String frame) {
                                    return DropdownMenuItem<String>(
                                      value: frame,
                                      child: Text(frame, style: const TextStyle(color: Colors.white)),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedAsset = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // इंजेक्ट बटन
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.stars),
                            label: const Text("Inject Premium Asset Instantly", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            onPressed: () {
                              if (userUidController.text.isEmpty || selectedAsset == null) {
                                Get.snackbar("Validation Error", "Target UID and Reward Item selection are mandatory.",
                                    backgroundColor: Colors.redAccent, colorText: Colors.white, maxWidth: 450);
                                return;
                              }

                              Get.dialog(
                                AlertDialog(
                                  backgroundColor: const Color(0xFF1E1E2E),
                                  title: const Row(
                                    children: [
                                      Icon(Icons.gavel, color: Colors.green),
                                      SizedBox(width: 8),
                                      Text("Asset Injected", style: TextStyle(color: Colors.white, fontSize: 18)),
                                    ],
                                  ),
                                  content: Text(
                                      "Item '$selectedAsset' has been successfully credited to User UID ${userUidController.text} for ${durationController.text} days."),
                                  actions: [
                                    TextButton(
                                      child: const Text("Acknowledge", style: TextStyle(color: Colors.orange)),
                                      onPressed: () {
                                        Get.back();
                                        userUidController.clear();
                                        setState(() {
                                          selectedAsset = null;
                                        });
                                      },
                                    )
                                  ],
                                ),
                              );
                            },
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

  // टेक्स्ट फ़ील्ड बनाने का हेल्पर विजेट
  Widget _buildTextField({required String label, required String hint, required TextEditingController controller, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.orange, size: 20),
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