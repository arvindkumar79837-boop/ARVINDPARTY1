import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/family_controller.dart';

class FamilySettingsScreen extends StatelessWidget {
  const FamilySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FamilyController>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('Family Settings', style: TextStyle(color: Colors.white, fontSize: 20)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            final family = controller.myFamily.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFamilyProfileSection(controller, family),
                const SizedBox(height: 24),
                _buildRolePermissionsSection(),
                const SizedBox(height: 24),
                _buildRoomSettingsSection(),
                const SizedBox(height: 24),
                _buildChatSettingsSection(),
                const SizedBox(height: 24),
                _buildDangerZoneSection(controller),
                const SizedBox(height: 80),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildFamilyProfileSection(FamilyController controller, Map<String, dynamic>? family) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Family Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
                    backgroundColor: Colors.deepPurple.withValues(alpha: 0.2),
                    child: Text(
                      (family?['family_name'] as String? ?? 'F')[0].toUpperCase(),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF1A1A2E), width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSettingField(label: 'Family Name', value: family?['family_name'] ?? 'My Family'),
              const SizedBox(height: 12),
              _buildSettingField(label: 'Badge', value: family?['badge'] ?? 'FAM'),
              const SizedBox(height: 12),
              _buildSettingField(label: 'Slogan', value: family?['slogan'] ?? 'Together we rise'),
              const SizedBox(height: 12),
              _buildSettingField(label: 'Family ID', value: family?['family_id'] ?? 'N/A', isCopyable: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingField({required String label, required String value, bool isCopyable = false}) {
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
          if (isCopyable)
            IconButton(
              icon: Icon(Icons.copy, color: Colors.deepPurple.withValues(alpha: 0.6), size: 18),
              onPressed: () {
                Get.snackbar('Copied', 'Family ID copied to clipboard',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.deepPurple.withValues(alpha: 0.8),
                    colorText: Colors.white);
              },
            )
          else
            Icon(Icons.edit_outlined, color: Colors.deepPurple.withValues(alpha: 0.6), size: 18),
        ],
      ),
    );
  }

  Widget _buildRolePermissionsSection() {
    final roles = [
      {
        'role': 'Owner',
        'color': Colors.red,
        'icon': Icons.admin_panel_settings_outlined,
        'permissions': ['Full Access', 'Manage Members', 'Wallet', 'Delete Family'],
      },
      {
        'role': 'Admin',
        'color': Colors.orange,
        'icon': Icons.shield_outlined,
        'permissions': ['Manage Members', 'Wallet', 'Events'],
      },
      {
        'role': 'Member',
        'color': Colors.blue,
        'icon': Icons.person_outlined,
        'permissions': ['Chat', 'Tasks', 'Contribute'],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Roles & Permissions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        ...roles.map((r) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: (r['color'] as Color).withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: (r['color'] as Color).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(r['icon'] as IconData, color: r['color'] as Color, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Text(r['role'] as String, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: r['color'] as Color)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: (r['permissions'] as List<String>)
                        .map((p) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(p, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7))),
                            ))
                        .toList(),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildRoomSettingsSection() {
    final settings = [
      {'title': 'Official Room', 'subtitle': 'Set the default family room', 'value': 'Arvind\'s Room', 'icon': Icons.meeting_room_outlined},
      {'title': 'Max Members', 'subtitle': 'Maximum family size', 'value': '50', 'icon': Icons.people_outline},
      {'title': 'Auto-Admit', 'subtitle': 'Automatically accept invitations', 'value': 'Off', 'icon': Icons.how_to_reg_outlined},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Room Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: settings.map((s) {
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                leading: Icon(s['icon'] as IconData, color: Colors.deepPurple.withValues(alpha: 0.7)),
                title: Text(s['title'] as String, style: const TextStyle(fontSize: 14, color: Colors.white)),
                subtitle: Text(s['subtitle'] as String, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(s['value'] as String, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7))),
                    const SizedBox(width: 4),
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

  Widget _buildChatSettingsSection() {
    final toggles = [
      {'title': 'Family Chat', 'subtitle': 'Enable group chat for family', 'value': true},
      {'title': 'Allow GIFs', 'subtitle': 'Allow sending GIFs in chat', 'value': true},
      {'title': 'Message Pinning', 'subtitle': 'Allow admins to pin messages', 'value': true},
      {'title': 'Read Receipts', 'subtitle': 'Show read status to members', 'value': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Chat Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
                      'Chat Setting Updated',
                      '${t['title']} ${val ? 'enabled' : 'disabled'}',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.deepPurple.withValues(alpha: 0.8),
                      colorText: Colors.white,
                    );
                  },
                  activeColor: Colors.deepPurple,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDangerZoneSection(FamilyController controller) {
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
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.exit_to_app, color: Colors.orange.withValues(alpha: 0.7)),
                title: const Text('Leave Family', style: TextStyle(fontSize: 14, color: Colors.white)),
                subtitle: Text(
                  'You will lose all family benefits',
                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5)),
                ),
                trailing: Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.3)),
                onTap: () => _showLeaveDialog(controller),
              ),
              const Divider(color: Colors.white10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.delete_forever_outlined, color: Colors.red.withValues(alpha: 0.7)),
                title: const Text('Disband Family', style: TextStyle(fontSize: 14, color: Colors.white)),
                subtitle: Text(
                  'Permanently delete the family',
                  style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5)),
                ),
                trailing: Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.3)),
                onTap: () => _showDisbandDialog(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLeaveDialog(FamilyController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text('Leave Family?', style: TextStyle(color: Colors.orange)),
        content: const Text(
          'Are you sure you want to leave? You will lose access to family chat, tasks, and treasury.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.leaveFamily();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Leave', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDisbandDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text('Disband Family?', style: TextStyle(color: Colors.red)),
        content: const Text(
          'This action cannot be undone. All family data, chat history, and treasury will be permanently deleted.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Disband', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
