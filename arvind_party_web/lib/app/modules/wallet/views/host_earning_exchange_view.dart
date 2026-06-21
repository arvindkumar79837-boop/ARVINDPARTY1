import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HostEarningExchangeView extends StatefulWidget {
  const HostEarningExchangeView({Key? key}) : super(key: key);

  @override
  State<HostEarningExchangeView> createState() => _HostEarningExchangeViewState();
}

class _HostEarningExchangeViewState extends State<HostEarningExchangeView> {
  // लाइव अर्निंग ट्रैकिंग (डमी स्टेट - जो बैकएंड से सिंक होगी)
  int currentDiamonds = 45000;
  int currentCoins = 2500;
  
  // ओनर द्वारा सेट की गई सेटिंग्स (जो आपके बैकएंड API से आएगी)
  int targetThreshold = 40000;      // 40k डायमंड का मिनिमम टारगेट
  double ownerCuttingPercent = 50.0; // 50-50 कटिंग रेशियो

  final TextEditingController exchangeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool isTargetAchieved = currentDiamonds >= targetThreshold;

    return Scaffold(
      backgroundColor: const Color(0xFF14141F), // ऐप की प्रीमियम डार्क थीम
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2E),
        elevation: 0,
        title: const Text("Host Earning Center", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. लाइव अर्निंग और वॉलेट बैलेंसेज कार्ड्स
            Row(
              children: [
                Expanded(
                  child: _buildWalletCard(
                    title: "My Diamonds (Earnings)",
                    value: currentDiamonds.toString(),
                    icon: Icons.diamond,
                    iconColor: Colors.cyanAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildWalletCard(
                    title: "My Coins (Wallet)",
                    value: currentCoins.toString(),
                    icon: Icons.monetization_on,
                    iconColor: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 2. लाइव टारगेट प्रोग्रेस बार (Target Audit Track)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2D2D44)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Current Cycle Target", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isTargetAchieved ? Colors.green.withOpacity(0.1) : Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isTargetAchieved ? "Target Achieved ✔" : "Pending Target ⏳",
                          style: TextStyle(color: isTargetAchieved ? Colors.green : Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: (currentDiamonds / targetThreshold).clamp(0.0, 1.0),
                    backgroundColor: const Color(0xFF14141F),
                    valueColor: AlwaysStoppedAnimation<Color>(isTargetAchieved ? Colors.green : Colors.orange),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("$currentDiamonds / $targetThreshold Diamonds", style: const TextStyle(color: Colors.white30, fontSize: 12)),
                      Text("${((currentDiamonds / targetThreshold) * 100).toStringAsFixed(0)}%", style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. डायमंड टू कॉइन एक्सचेंज पोर्टल (50-50 Cutting Console)
            Container(
              padding: const EdgeInsets.all(16),
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
                      Icon(Icons.currency_exchange, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Text("Convert Diamonds to Coins", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Note: Exchange is subject to a ${ownerCuttingPercent.toStringAsFixed(0)}-${(100 - ownerCuttingPercent).toStringAsFixed(0)} system revenue cut configuration set by administration.",
                    style: const TextStyle(color: Colors.white30, fontSize: 11),
                  ),
                  const Divider(color: Color(0xFF2D2D44), height: 24),

                  // इनपुट फील्ड
                  TextField(
                    controller: exchangeController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: "Enter amount of diamonds to convert...",
                      hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF14141F),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF3D3D5C))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.orange)),
                    ),
                    onChanged: (val) {
                      setState(() {}); // री-कैलकुलेशन लाइव दिखाने के लिए
                    },
                  ),
                  const SizedBox(height: 16),

                  // लाइव कैलकुलेशन प्रीव्यू बॉक्स
                  if (exchangeController.text.isNotEmpty) _buildCalculationPreview(),

                  const SizedBox(height: 16),

                  // सबमिट बटन
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isTargetAchieved ? Colors.orange : Colors.grey.shade800,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: isTargetAchieved ? () => _processExchange() : null,
                      child: Text(
                        isTargetAchieved ? "Authorize Instant Conversion" : "Locked (Complete Target First)",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // लाइव कैलकुलेशन दिखाने का विजेट
  Widget _buildCalculationPreview() {
    int inputDiamonds = int.tryParse(exchangeController.text) ?? 0;
    // 50% कटिंग के बाद मिलने वाले कॉइन्स का मैथ लॉजिक
    int userReceivesCoins = (inputDiamonds * ((100 - ownerCuttingPercent) / 100)).parseInt();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF14141F), borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Diamonds Deducted:", style: TextStyle(color: Colors.white54, fontSize: 12)),
              Text("-$inputDiamonds", style: const TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Admin Cutting (${ownerCuttingPercent.toStringAsFixed(0)}%):", style: const TextStyle(color: Colors.white54, fontSize: 12)),
              Text("-${(inputDiamonds * (ownerCuttingPercent / 100)).toStringAsFixed(0)}", style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
            ],
          ),
          const Divider(color: Colors.white10, height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Coins Credited to Wallet:", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              Text("+$userReceivesCoins Coins", style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // एक्सचेंज प्रोसेस करने का एक्शन
  void _processExchange() {
    int diamondsToConvert = int.tryParse(exchangeController.text) ?? 0;
    if (diamondsToConvert <= 0 || diamondsToConvert > currentDiamonds) {
      Get.snackbar("Invalid Amount", "You do not have enough diamonds to complete this request.",
          backgroundColor: Colors.redAccent, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    int coinsGained = (diamondsToConvert * ((100 - ownerCuttingPercent) / 100)).parseInt();

    setState(() {
      currentDiamonds -= diamondsToConvert;
      currentCoins += coinsGained;
    });

    exchangeController.clear();

    Get.defaultDialog(
      backgroundColor: const Color(0xFF1E1E2E),
      title: "Conversion Successful",
      titleStyle: const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
      middleText: "Your diamonds have been securely audited. $coinsGained Coins added to your flying wallet.",
      middleTextStyle: const TextStyle(color: Colors.white70, fontSize: 13),
      textConfirm: "Perfect",
      confirmTextColor: Colors.white,
      buttonColor: Colors.orange,
      onConfirm: () => Get.back(),
    );
  }

  // बैलेंसेस कार्ड्स बनाने का हेल्पर विजेट
  Widget _buildWalletCard({required String title, required String value, required IconData icon, required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2D2D44)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Colors.white30, fontSize: 11, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}

/// एक्सटेंशन ताकि डबल वैल्यू आराम से इंटीजर कॉइन बन सके
extension on double {
  int parseInt() => toInt();
}