// ═══════════════════════════════════════════════════════════════════════════
// FILE: arvind_party_web/lib/modules/owner/views/coin_generation_view.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:arvind_party/arvind_party_web/lib/core/constants/api_constants.dart';

class CoinGenerationView extends StatefulWidget {
  const CoinGenerationView({super.key});

  @override
  State<CoinGenerationView> createState() => _CoinGenerationViewState();
}

class _CoinGenerationViewState extends State<CoinGenerationView> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  bool _isGenerating = false;
  int _treasuryBalance = 5000000; // Dummy initial balance

  void _handleGenerate() {
    final amountText = _amountController.text.trim();
    final reason = _reasonController.text.trim();

    if (amountText.isEmpty ||
        int.tryParse(amountText) == null ||
        int.parse(amountText) <= 0) {
      Get.snackbar('Invalid Input', 'Please enter a valid coin amount.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    if (reason.isEmpty) {
      Get.snackbar('Missing Reason', 'Please provide a reason for auditing.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final amount = int.parse(amountText);

    // CRITICAL: Double Confirmation Dialog
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF15141F),
        title: const Text('⚠️ CRITICAL ACTION',
            style: TextStyle(
                color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: Text(
          'You are about to generate $amount coins to the central treasury.\n\nReason: "$reason"\n\nAre you sure you want to proceed? This action will be permanently logged.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child:
                const Text('CANCEL', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Get.back();
              _executeCoinGeneration(amount);
            },
            child: const Text('CONFIRM GENERATE',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _executeCoinGeneration(int amount) async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final token = GetStorage().read('staff_token');
      final response = await http.post(
        Uri.parse('${ApiConstants.apiBaseUrl}/treasury/generate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'amount': amount,
          'reason': _reasonController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode != 200 || data['success'] != true) {
        throw Exception(data['message'] ?? 'Failed to generate coins');
      }
    } catch (e) {
      setState(() => _isGenerating = false);
      Get.snackbar('Error', e.toString().replaceAll('Exception: ', ''),
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() {
      _treasuryBalance += amount;
      _isGenerating = false;
      _amountController.clear();
      _reasonController.clear();
    });

    Get.snackbar(
      'Success',
      '$amount coins have been securely generated and added to Treasury.',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── HEADER & TREASURY BALANCE ───
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearFromGradient(
                colors: [Color(0xFF2B2118), Color(0xFF15141F)],
              ),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: Colors.yellow.withOpacity(0.3), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CENTRAL TREASURY BALANCE',
                        style: TextStyle(
                            color: Colors.yellow,
                            fontSize: 14,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      '🪙 ${_treasuryBalance.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Icon(Icons.account_balance,
                    size: 80, color: Colors.white12),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ─── COIN GENERATION FORM ───
          const Text('Mint New Coins',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
              'Strictly restricted to OWNER. All generation events are permanently recorded in the system audit logs.',
              style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 24),

          Container(
            width: 600,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'Coin Amount to Generate',
                    labelStyle:
                        const TextStyle(color: Colors.white54, fontSize: 16),
                    prefixIcon:
                        const Icon(Icons.monetization_on, color: Colors.yellow),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.3),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _reasonController,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Reason / Memo (Required)',
                    labelStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.3),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _handleGenerate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow.shade700,
                      foregroundColor: Colors.black,
                    ),
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child:
                                CircularProgressIndicator(color: Colors.black))
                        : const Icon(Icons.add_circle_outline),
                    label: Text(
                        _isGenerating ? 'GENERATING...' : 'GENERATE COINS',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class LinearFromGradient extends LinearGradient {
  const LinearFromGradient({required super.colors});
}
