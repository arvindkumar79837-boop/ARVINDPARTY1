import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DynamicGameCenterView extends StatefulWidget {
  const DynamicGameCenterView({Key? key}) : super(key: key);

  @override
  State<DynamicGameCenterView> createState() => _DynamicGameCenterViewState();
}

class _DynamicGameCenterViewState extends State<DynamicGameCenterView> {
  // टेक्स्ट फ़ील्ड्स को कंट्रोल करने के लिए
  final TextEditingController gameNameController = TextEditingController();
  final TextEditingController gameUrlController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController providerController = TextEditingController();

  String gameType = 'Owned'; // डिफ़ॉल्ट रूप से खुद का (Owned) गेम
  bool isPremiumOnly = false;

  // लाइव ऐडेड गेम्स की एक डमी लिस्ट (UI को समझाने के लिए)
  final List<Map<String, dynamic>> activeGames = [
    {
      'id': '1',
      'name': 'Ludo Classic',
      'type': 'Owned',
      'url': 'https://games.arvindparty.com/ludo',
      'status': 'Active'
    },
    {
      'id': '2',
      'name': 'Teen Patti Club',
      'type': 'Rented',
      'url': 'https://rentedgames.api/teenpatti',
      'status': 'Active'
    },
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
                    "Dynamic Game Center",
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Inject, modify, or rent HTML5/Web-based mini-games directly into the mobile application instantly.",
                    style: TextStyle(color: Color(0xA3FFFFFF), fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // बाएँ हाथ पर: नया गेम ऐड करने का फॉर्म
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
                                "Inject New Mini-Game",
                                style: TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 24),

                              _buildTextField(
                                label: "Game Title / Name",
                                hint: "e.g., Carrom Star, Fruit Ninja",
                                controller: gameNameController,
                                icon: Icons.sports_esports,
                              ),
                              const SizedBox(height: 20),

                              _buildTextField(
                                label: "Game Web URL (Hosted HTML5 Link)",
                                hint: "https://your-game-server.com/play/ or rented iFrame URL",
                                controller: gameUrlController,
                                icon: Icons.link,
                              ),
                              const SizedBox(height: 20),

                              _buildTextField(
                                label: "Game Thumbnail Image URL",
                                hint: "https://cdn.arvindparty.com/images/game_thumb.png",
                                controller: imageUrlController,
                                icon: Icons.image,
                              ),
                              const SizedBox(height: 20),

                              Row(
                                children: [
                                  // गेम का प्रकार (Owned या Rented)
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Game Acquisition Type", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
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
                                              value: gameType,
                                              dropdownColor: const Color(0xFF1E1E2E),
                                              isExpanded: true,
                                              icon: const Icon(Icons.arrow_drop_down, color: Colors.orange),
                                              items: ['Owned', 'Rented'].map((String type) {
                                                return DropdownMenuItem<String>(
                                                  value: type,
                                                  child: Text(type, style: const TextStyle(color: Colors.white)),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  gameType = value!;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  // वेंडर / प्रोवाइडर का नाम
                                  Expanded(
                                    child: _buildTextField(
                                      label: "Provider / Vendor Name",
                                      hint: "e.g., Internal Dev, GameZap Rent Co.",
                                      controller: providerController,
                                      icon: Icons.business_center,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              SwitchListTile(
                                 title: Text("Restrict to VIP Members Only", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                                value: isPremiumOnly,
                                activeColor: Colors.orange,
                                onChanged: (val) => setState(() => isPremiumOnly = val),
                              ),
                              const SizedBox(height: 24),

                              // पब्लिश बटन
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  icon: const Icon(Icons.rocket_launch),
                                  label: const Text("Publish Game Live to Mobile App", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  onPressed: () {
                                    if (gameNameController.text.isEmpty || gameUrlController.text.isEmpty) {
                                      Get.snackbar("Error", "Game Title and Web URL are mandatory fields.",
                                          backgroundColor: Colors.redAccent, colorText: Colors.white, maxWidth: 450);
                                      return;
                                    }

                                    setState(() {
                                      activeGames.add({
                                        'id': (activeGames.length + 1).toString(),
                                        'name': gameNameController.text,
                                        'type': gameType,
                                        'url': gameUrlController.text,
                                        'status': 'Active'
                                      });
                                    });

                                    Get.snackbar("Success", "${gameNameController.text} injected successfully into app routing.",
                                        backgroundColor: Colors.green, colorText: Colors.white, maxWidth: 450);

                                    // फॉर्म रीसेट करें
                                    gameNameController.clear();
                                    gameUrlController.clear();
                                    imageUrlController.clear();
                                    providerController.clear();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),

                      // दाएँ हाथ पर: लाइव चल रहे गेम्स की लिस्ट
                      Expanded(
                        flex: 2,
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
                                "Live App Mini-Games",
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const Divider(color: Color(0xFF2D2D44), height: 32),
                              
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: activeGames.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final game = activeGames[index];
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
                                            Text(game['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                            const SizedBox(height: 4),
                                            Text("Type: ${game['type']}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(game['status'], style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                              onPressed: () {
                                                setState(() {
                                                  activeGames.removeAt(index);
                                                });
                                              },
                                            )
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
}