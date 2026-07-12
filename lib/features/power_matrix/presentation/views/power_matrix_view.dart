// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/power_matrix/presentation/views/power_matrix_view.dart
// ARVIND PARTY - POWER MATRIX MOBILE VIEW
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/power_matrix_model.dart';
import '../controllers/power_matrix_controller.dart';

class PowerMatrixView extends GetView<PowerMatrixController> {
  const PowerMatrixView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Power Matrix Info'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value, style: const TextStyle(color: Colors.red)));
        }
        if (controller.powerMatrix.value == null) {
          return const Center(child: Text('No Power Matrix configured.'));
        }

        final powerMatrix = controller.powerMatrix.value!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGlobalSettingsDisplay(context, powerMatrix.globalSettings),
              const SizedBox(height: 20),
              _buildUserPowerCheckSection(context),
              const SizedBox(height: 20),
              _buildCurrentLevelRules(context, powerMatrix.rules),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildGlobalSettingsDisplay(BuildContext context, PowerMatrixGlobalSettings settings) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Global Power Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSettingRow('Owner Can Override All:', settings.ownerCanOverrideAll ? 'Yes' : 'No'),
            _buildSettingRow('Admin Can Override VIP:', settings.adminCanOverrideVip ? 'Yes' : 'No'),
            _buildSettingRow('SVIP Immunity Level:', settings.svipImmunityLevel.toString()),
            _buildSettingRow('VIP Immunity Level:', settings.vipImmunityLevel.toString()),
            _buildSettingRow('Level Difference Required:', settings.levelDifferenceRequired.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: const TextStyle(fontSize: 16)), Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))],
      ),
    );
  }

  Widget _buildUserPowerCheckSection(BuildContext context) {
    final targetUserIdController = TextEditingController();
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Check User Authority',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: targetUserIdController,
              decoration: const InputDecoration(
                labelText: 'Target User ID',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => DropdownButtonFormField<String>(
                      initialValue: controller.checkAction.value,
                      decoration: const InputDecoration(
                        labelText: 'Action',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'mute', child: Text('Mute')),
                        DropdownMenuItem(value: 'kick', child: Text('Kick')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          controller.checkAction.value = value;
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => controller.checkUserPower(targetUserIdController.text, controller.checkAction.value),
                  child: const Text('Check'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              final result = controller.lastCheckResult.value;
              if (result != null) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: controller.getPowerCheckColor(result).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: controller.getPowerCheckColor(result)),
                  ),
                  child: Text(
                    controller.getPowerCheckDescription(result),
                    style: TextStyle(
                      color: controller.getPowerCheckColor(result),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLevelRules(BuildContext context, List<PowerMatrixRule> rules) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'All Level Rules',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...rules.map((rule) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Level ${rule.level}:', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  Expanded(
                    child: Text(
                      'Mute: ${rule.canMuteLowerLevels ? "Yes" : "No"}, Kick: ${rule.canKickLowerLevels ? "Yes" : "No"}',
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}