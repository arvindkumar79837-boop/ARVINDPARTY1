// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/settings/presentation/views/settings_screen.dart
// ARVIND PARTY - ACCOUNT SETTINGS & PRIVACY SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Settings & Privacy',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Color(0xFFFF9800)),
            onPressed: controller.saveAllSettings,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Language & Region', Icons.language),
              const SizedBox(height: 8),
              _buildLanguageSelector(controller),
              const SizedBox(height: 24),

              _buildSectionHeader('Privacy Controls', Icons.privacy_tip),
              const SizedBox(height: 8),
              _buildPrivacySection(controller),
              const SizedBox(height: 24),

              _buildSectionHeader('Notifications', Icons.notifications),
              const SizedBox(height: 8),
              _buildNotificationSection(controller),
              const SizedBox(height: 24),

              _buildSectionHeader('Storage & Cache', Icons.storage),
              const SizedBox(height: 8),
              _buildCacheSection(controller),
              const SizedBox(height: 24),

              _buildSectionHeader('Account', Icons.account_circle),
              const SizedBox(height: 8),
              _buildAccountSection(controller),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF9800), size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector(SettingsController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A4E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromARGB(255, 255, 255, 255).withValues(alpha: 0.1)),
      ),
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('App Language', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.languages.map((lang) {
                  final isSelected = controller.selectedLanguage.value == lang.code;
                  return GestureDetector(
                    onTap: () => controller.setLanguage(lang),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFF9800) : const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFFF9800) : Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Text(
                        '${lang.flagEmoji} ${lang.nativeName}',
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white70,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          )),
    );
  }

  Widget _buildPrivacySection(SettingsController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A4E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Obx(() => Column(
            children: [
              _buildPrivacyToggle(controller, 'Show Online Status',
                  controller.showOnlineStatus.value, controller.toggleOnlineStatus),
              const Divider(color: Colors.white10, height: 24),
              _buildPrivacyToggle(controller, 'Show Last Seen',
                  controller.showLastSeen.value, controller.toggleLastSeen),
              const Divider(color: Colors.white10, height: 24),
              _buildPrivacyToggle(controller, 'Allow Friend Requests',
                  controller.allowFriendRequests.value, controller.toggleFriendRequests),
              const Divider(color: Colors.white10, height: 24),
              _buildPrivacyToggle(controller, 'Allow Private Messages',
                  controller.allowPrivateMessages.value, controller.togglePrivateMessages),
              const Divider(color: Colors.white10, height: 24),
              _buildPrivacyToggle(controller, 'Allow Gifts',
                  controller.allowGifts.value, controller.toggleGifts),
              const Divider(color: Colors.white10, height: 24),
              _buildPrivacyToggle(controller, 'Show Wallet Balance',
                  controller.showWalletBalance.value, controller.toggleWalletBalance),
              const Divider(color: Colors.white10, height: 24),
              _buildPrivacyToggle(controller, 'Show in Search',
                  controller.showInSearch.value, controller.toggleSearchVisibility),
              const Divider(color: Colors.white10, height: 24),
              _buildPrivacyToggle(controller, 'Data Collection for Analytics',
                  controller.allowDataCollection.value, controller.toggleDataCollection),
            ],
          )),
    );
  }

  Widget _buildPrivacyToggle(SettingsController controller, String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: const Color(0xFFFF9800),
          activeTrackColor: const Color(0xFFFF9800).withValues(alpha: 0.3),
        ),
      ],
    );
  }

  Widget _buildNotificationSection(SettingsController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A4E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Obx(() => Column(
            children: [
              _buildPrivacyToggle(controller, 'Push Notifications',
                  controller.pushEnabled.value, controller.togglePush),
              const Divider(color: Colors.white10, height: 24),
              _buildPrivacyToggle(controller, 'Sound',
                  controller.soundEnabled.value, controller.toggleSound),
              const Divider(color: Colors.white10, height: 24),
              _buildPrivacyToggle(controller, 'Vibration',
                  controller.vibrationEnabled.value, controller.toggleVibration),
            ],
          )),
    );
  }

  Widget _buildCacheSection(SettingsController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A4E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Obx(() => Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.cleaning_services, color: Color(0xFFFF9800), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cache Size', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                    Text(controller.cacheSize.value,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: controller.clearCache,
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.cacheCleared.value
                      ? Colors.green
                      : const Color(0xFFFF9800),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  controller.cacheCleared.value ? 'Cleared!' : 'Clear',
                  style: TextStyle(
                    color: controller.cacheCleared.value ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildAccountSection(SettingsController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A4E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _buildAccountOption(Icons.person, 'Edit Profile', () {
            _showEditProfileDialog(controller);
          }),
          const Divider(color: Colors.white10, height: 24),
          _buildAccountOption(Icons.support_agent, 'Contact Support', () {
            _showSupportDialog(controller);
          }),
          const Divider(color: Colors.white10, height: 24),
          _buildAccountOption(Icons.inbox, 'Agency Invitations', () {
            _showInboxDialog(controller);
          }),
          const Divider(color: Colors.white10, height: 24),
          _buildAccountOption(Icons.security, 'Security Center', () {}),
          const Divider(color: Colors.white10, height: 24),
          _buildAccountOption(Icons.link, 'Linked Accounts', () {}),
          const Divider(color: Colors.white10, height: 24),
          _buildAccountOption(Icons.delete_sweep, 'Delete Account', () {
            _showDeleteAccountDialog(controller);
          }, textColor: Colors.red),
        ],
      ),
    );
  }

  Widget _buildAccountOption(IconData icon, String title, VoidCallback onTap, {Color? textColor}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: textColor ?? const Color(0xFFFF9800), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.3), size: 20),
        ],
      ),
    );
  }

  void _showEditProfileDialog(SettingsController controller) {
    final nameController = TextEditingController(text: controller.userName.value);
    final bioController = TextEditingController(text: controller.userBio.value);
    
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A4E),
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bioController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Bio',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              controller.updateProfile(data: {
                'name': nameController.text,
                'bio': bioController.text,
              });
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF9800)),
            child: const Text('Save', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(SettingsController controller) {
    final passwordController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A4E),
        title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This action cannot be undone. All your data will be permanently deleted.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              style: const TextStyle(color: Colors.white),
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Enter Password',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              if (passwordController.text.isNotEmpty) {
                controller.deleteAccount(passwordController.text);
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Forever', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(SettingsController controller) {
    final subjectController = TextEditingController();
    final messageController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A4E),
        title: const Text('Contact Support', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Subject',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              style: const TextStyle(color: Colors.white),
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Describe your issue',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              if (subjectController.text.isNotEmpty && messageController.text.isNotEmpty) {
                controller.createTicket(subjectController.text, messageController.text);
                Get.back();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF9800)),
            child: const Text('Send', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showInboxDialog(SettingsController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A4E),
        title: const Text('Agency Invitations', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Obx(() {
            if (controller.tickets.isEmpty) {
              return const Center(
                child: Text('No pending invitations', style: TextStyle(color: Colors.white70)),
              );
            }
            return ListView.builder(
              itemCount: controller.tickets.length,
              itemBuilder: (context, index) {
                final ticket = controller.tickets[index];
                return Card(
                  color: const Color(0xFF1A1A2E),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(ticket['subject'] ?? 'Invitation', style: const TextStyle(color: Colors.white)),
                    subtitle: Text(
                      ticket['message'] ?? '',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            controller.replyToTicket(
                              ticket['_id'],
                              'Accepted',
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            controller.replyToTicket(
                              ticket['_id'],
                              'Rejected',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}
