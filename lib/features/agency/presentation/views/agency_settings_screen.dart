import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/agency_controller.dart';

class AgencySettingsScreen extends StatelessWidget {
  const AgencySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AgencyController>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('Agency Settings', style: TextStyle(color: Colors.white, fontSize: 20)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAgencyProfileSection(controller),
              const SizedBox(height: 24),
              _buildCommissionSection(),
              const SizedBox(height: 24),
              _buildNotificationSection(),
              const SizedBox(height: 24),
              _buildDangerZoneSection(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgencyProfileSection(AgencyController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Agency Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.orange.withValues(alpha: 0.2),
                    child: const Icon(Icons.business, color: Colors.orange, size: 40),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF1A1A2E), width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildEditableField(label: 'Agency Name', value: 'Arvind Party Agency'),
              const SizedBox(height: 12),
              _buildEditableField(label: 'Description', value: 'Premier entertainment agency'),
              const SizedBox(height: 12),
              _buildEditableField(label: 'Contact Email', value: 'admin@arvindparty.com'),
              const SizedBox(height: 12),
              _buildEditableField(label: 'Contact Phone', value: '+91 98765 43210'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 14, color: Colors.white)),
              ],
            ),
          ),
          Icon(Icons.edit_outlined, color: Colors.orange.withValues(alpha: 0.6), size: 18),
        ],
      ),
    );
  }

  Widget _buildCommissionSection() {
    final settings = [
      {'label': 'Host Commission', 'value': '60%', 'desc': 'Commission rate for hosts'},
      {'label': 'Agent Commission', 'value': '25%', 'desc': 'Commission rate for agents'},
      {'label': 'Agency Share', 'value': '15%', 'desc': 'Agency operational share'},
      {'label': 'Bonus Pool', 'value': '5%', 'desc': 'Monthly bonus allocation'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Commission Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: settings.map((s) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s['label']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                          const SizedBox(height: 2),
                          Text(s['desc']!, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(s['value']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.orange)),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.3), size: 20),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    final toggles = [
      {'title': 'Live Session Alerts', 'subtitle': 'Notify when hosts go live', 'value': true},
      {'title': 'Revenue Reports', 'subtitle': 'Weekly revenue summaries', 'value': true},
      {'title': 'Member Activity', 'subtitle': 'New member join/leave alerts', 'value': false},
      {'title': 'System Updates', 'subtitle': 'Platform updates and changes', 'value': true},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: toggles.map((t) {
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                title: Text(t['title'] as String, style: const TextStyle(fontSize: 14, color: Colors.white)),
                subtitle: Text(t['subtitle'] as String, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
                trailing: Switch(
                  value: t['value'] as bool,
                  onChanged: (val) {
                    t['value'] = val;
                    Get.snackbar(
                      'Notification Updated',
                      '${t['title']} ${val ? 'enabled' : 'disabled'}',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.orange.withValues(alpha: 0.8),
                      colorText: Colors.white,
                    );
                  },
                  activeThumbColor: Colors.orange,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDangerZoneSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Danger Zone', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              _buildDangerAction(
                'Transfer Ownership',
                'Transfer agency ownership to another member',
                Icons.transfer_within_a_station,
                () {
                  Get.dialog(
                    AlertDialog(
                      backgroundColor: const Color(0xFF2A2A3E),
                      title: const Text('Transfer Ownership?', style: TextStyle(color: Colors.orange)),
                      content: const Text(
                        'This will transfer agency ownership to another member. This action requires admin approval.',
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
                        ElevatedButton(
                          onPressed: () {
                            Get.back();
                            Get.snackbar('Transfer Initiated', 'Ownership transfer request sent',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.orange.withValues(alpha: 0.8),
                                colorText: Colors.white);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                          child: const Text('Transfer', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Divider(color: Colors.white10),
              _buildDangerAction(
                'Dissolve Agency',
                'Permanently delete this agency',
                Icons.delete_forever_outlined,
                () => _showDissolveDialog(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDangerAction(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.red.withValues(alpha: 0.7)),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
      trailing: Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.3)),
      onTap: onTap,
    );
  }

  void _showDissolveDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text('Dissolve Agency?', style: TextStyle(color: Colors.red)),
        content: const Text(
          'This action cannot be undone. All agency data, member records, and earnings history will be permanently deleted.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Dissolve', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
