import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/role_auth_controller.dart'; // अपने कंट्रोलर का सही पाथ दें

class AdminRolesView extends StatefulWidget {
  const AdminRolesView({super.key});

  @override
  State<AdminRolesView> createState() => _AdminRolesViewState();
}

class _AdminRolesViewState extends State<AdminRolesView> {
  final RoleAuthController authController = Get.find<RoleAuthController>();

  // यूआई कंट्रोलर टेक्स्ट फ़ील्ड्स
  final TextEditingController uidController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // आपकी लिस्ट के हिसाब से ड्रॉप-डाउन के लिए सभी 15+ रोल्स की स्ट्रिंग लिस्ट
  final List<String> availableRoles = [
    'OWNER.WEB',
    'APP.ADMIN.WEB',
    'GLOBAL.MANAGER.WEB',
    'COUNTRY.MANAGER.WEB',
    'SUPER.ADMIN.UID',
    'ADMIN.UID',
    'BD.UID',
    'SUPER.COIN.SELLER.UID',
    'NORMAL.COIN.SELLER.UID',
    'CS.CUSTOMER.SERVICE.UID',
    'CS.LEADER.UID',
    'OWNER.ASSISTANT.UID',
    'ADMIN.ASSISTANT.UID',
    'GLOBAL.MANAGER.ASSISTANT.UID',
    'Official web panel',
    'Official assistant UID panel'
  ];

  String? selectedRole;

  // परमिशन चेकर स्टेट्स (UI के स्विच के लिए)
  bool genCoins = false;
  bool transCoins = false;
  bool appWithdrawal = false;
  bool mgtStaff = false;
  bool changeBanners = false;
  bool giveFrames = false;
  bool mgtAgencies = false;
  bool addGames = false;
  bool banUsers = false;
  bool lockPassword = true; // स्टाफ के लिए हमेशा डिफ़ॉल्ट true रहेगा

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF14141F), // डीप डार्क बैकग्राउंड
      body: Row(
        children: [
          // नोट: जब आप पूरा ढांचा जोड़ेंगे तो साइडबार यहाँ दिखेगा
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // हेडर टाइटल
                  const Text(
                    "Role & Permissions Management",
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Invite platform users via their UID and assign specific role privileges.",
                    style: TextStyle(color: Color(0xA3FFFFFF), fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  // मेन फॉर्म कार्ड
                  Container(
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
                          "Invite New Staff Member",
                          style: TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),

                        // इनपुट रो (UID और नाम)
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: "Target User UID",
                                hint: "Enter user unique ID (e.g. 798372)",
                                controller: uidController,
                                icon: Icons.fingerprint,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _buildTextField(
                                label: "Staff Reference Name",
                                hint: "Enter name (e.g. Amit Kumar)",
                                controller: nameController,
                                icon: Icons.person_add_alt,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // रोल ड्रॉप-डाउन मेनू
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Select Assignment Role", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
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
                                  value: selectedRole,
                                  hint: const Text("Choose a role from matrix...", style: TextStyle(color: Colors.white30)),
                                  dropdownColor: const Color(0xFF1E1E2E),
                                  isExpanded: true,
                                  icon: const Icon(Icons.arrow_drop_down, color: Colors.orange),
                                  items: availableRoles.map((String role) {
                                    return DropdownMenuItem<String>(
                                      value: role,
                                      child: Text(role, style: const TextStyle(color: Colors.white)),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedRole = value;
                                      // रोल के हिसाब से कुछ परमिशंस ऑटो-सेट करने का लॉजिक
                                      if (value == 'SUPER.COIN.SELLER.UID') {
                                        transCoins = true;
                                        genCoins = false;
                                      } else if (value == 'Official web panel') {
                                        appWithdrawal = true;
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // बारीक परमिशन चेकबॉक्सेस ग्रिड (Fine-grained Switch Matrix)
                        const Text(
                          "Custom Privilege Enforcements",
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Divider(color: Color(0xFF2D2D44), height: 24),
                        
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 4,
                          children: [
                            _buildSwitchTile("Can Generate Coins (Owner Exclusive)", genCoins, (val) => setState(() => genCoins = val)),
                            _buildSwitchTile("Can Transfer Coins", transCoins, (val) => setState(() => transCoins = val)),
                            _buildSwitchTile("Can Approve/Reject Withdrawals", appWithdrawal, (val) => setState(() => appWithdrawal = val)),
                            _buildSwitchTile("Can Invite & Manage Staff", mgtStaff, (val) => setState(() => mgtStaff = val)),
                            _buildSwitchTile("Can Modify App Banners", changeBanners, (val) => setState(() => changeBanners = val)),
                            _buildSwitchTile("Can Inject VIP Frames & Effects", giveFrames, (val) => setState(() => giveFrames = val)),
                            _buildSwitchTile("Can Manage System Agencies", mgtAgencies, (val) => setState(() => mgtAgencies = val)),
                            _buildSwitchTile("Can Add Dynamic Mini-Games (Own/Rent)", addGames, (val) => setState(() => addGames = val)),
                            _buildSwitchTile("Can Enforce User Bans", banUsers, (val) => setState(() => banUsers = val)),
                            _buildSwitchTile("Lock Panel Password (Staff Restrict)", lockPassword, (val) => setState(() => lockPassword = val)),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // इनविटेशन सबमिट बटन
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.send_rounded),
                            label: const Text("Generate and Send Official Role Invitation", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            onPressed: () {
                              if (uidController.text.isEmpty || nameController.text.isEmpty || selectedRole == null) {
                                Get.snackbar("Validation Error", "Please fill User UID, Name, and select a valid Role.",
                                    backgroundColor: Colors.redAccent, colorText: Colors.white, maxWidth: 450);
                                return;
                              }
                              
                              // यहाँ पर हम बाद में सीधे बैकएंड की रेस्ट एपीआई हिट करवा देंगे
                              Get.dialog(
                                AlertDialog(
                                  backgroundColor: const Color(0xFF1E1E2E),
                                  title: const Text("Invitation Transmitted", style: TextStyle(color: Colors.green)),
                                  content: Text("UID ${uidController.text} has been successfully invited as $selectedRole. Role will activate once they accept the in-app popup."),
                                  actions: [
                                    TextButton(
                                      child: const Text("OK", style: TextStyle(color: Colors.orange)),
                                      onPressed: () {
                                        Get.back();
                                        // फॉर्म क्लियर करें
                                        uidController.clear();
                                        nameController.clear();
                                        setState(() {
                                          selectedRole = null;
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

  // टेक्स्ट फ़ील्ड बनाने का हेल्पर
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
            prefixIcon: Icon(icon, color: Colors.orange),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
            filled: true,
            fillColor: const Color(0xFF14141F),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF3D3D5C))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.orange)),
          ),
        ),
      ],
    );
  }

  // स्विच टाइल बनाने का हेल्पर
  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, fontWeight: FontWeight.w400)),
      value: value,
      activeThumbColor: Colors.orange,
      activeTrackColor: Colors.orange.withValues(alpha: 0.3),
      inactiveThumbColor: Colors.white30,
      inactiveTrackColor: Colors.white10,
      onChanged: onChanged,
    );
  }
}