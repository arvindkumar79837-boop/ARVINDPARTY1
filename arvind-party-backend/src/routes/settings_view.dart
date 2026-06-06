import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late final SettingsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(SettingsController());
  }

  Widget _buildField(
      String label, TextEditingController textController, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: TextField(
        controller: textController,
        style: const TextStyle(color: Colors.white, fontSize: 18),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, color: const Color(0xFFFF8906)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Obx(() => controller.isLoading.value
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF8906)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('System Settings (Owner Only)',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                      'Change global variables directly influencing platform economy.',
                      style: TextStyle(color: Colors.white54)),
                  const SizedBox(height: 32),
                  SizedBox(
                      width: 600,
                      child: _buildField(
                          'Gift Commission (%) - Deducted from receivers',
                          controller.giftCommissionController,
                          Icons.percent)),
                  SizedBox(
                      width: 600,
                      child: _buildField('Withdrawal Fee (%)',
                          controller.withdrawalFeeController, Icons.money_off)),
                  SizedBox(
                      width: 600,
                      child: _buildField(
                          'Minimum Withdrawal Amount',
                          controller.minWithdrawalController,
                          Icons.account_balance_wallet)),
                  SizedBox(
                    width: 600,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: controller.isSaving.value
                          ? null
                          : () => controller.saveSettings(),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8906)),
                      child: controller.isSaving.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('SAVE SETTINGS',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                    ),
                  )
                ],
              ))),
    );
  }
}
