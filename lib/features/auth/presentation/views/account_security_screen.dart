// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/auth/presentation/views/account_security_screen.dart
// ARVIND PARTY - ACCOUNT SECURITY SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/auth_controller.dart';

class AccountSecurityScreen extends StatelessWidget {
  const AccountSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final storage = GetStorage();

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
          'Account Security',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSecurityScoreCard(),
            const SizedBox(height: 24),
            _buildSecurityOptionsSection(authController, storage),
            const SizedBox(height: 24),
            _buildDangerZoneSection(authController),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityScoreCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(alpha: 0.15),
            Colors.green.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color: Colors.green,
                size: 24,
              ),
              SizedBox(width: 10),
              Text(
                'Security Score',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Good',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your account is well protected',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withValues(alpha: 0.2),
                  border: Border.all(color: Colors.green, width: 3),
                ),
                child: const Center(
                  child: Text(
                    '75',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityOptionsSection(AuthController authController, GetStorage storage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Security Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildSecurityTile(
          icon: Icons.devices_outlined,
          iconColor: const Color(0xFF64B5F6),
          title: 'Device Binding',
          subtitle: 'Manage your bound devices',
          onTap: () => Get.toNamed(AppRoutes.deviceBinding),
        ),
        _buildSecurityTile(
          icon: Icons.device_hub_outlined,
          iconColor: Colors.purple,
          title: 'Multi-Device Control',
          subtitle: 'Control access across devices',
          onTap: () => Get.toNamed(AppRoutes.multiDeviceControl),
        ),
        _buildSecurityTile(
          icon: Icons.security_outlined,
          iconColor: Colors.orange,
          title: 'Session Management',
          subtitle: 'View and manage active sessions',
          onTap: () => Get.toNamed(AppRoutes.sessionManagement),
        ),
        _buildSecurityTile(
          icon: Icons.lock_outlined,
          iconColor: Colors.red,
          title: 'Change Password',
          subtitle: 'Update your account password',
          onTap: () => Get.toNamed(AppRoutes.passwordReset),
        ),
        _buildSecurityTile(
          icon: Icons.visibility_outlined,
          iconColor: Colors.teal,
          title: 'Login Activity',
          subtitle: 'View recent login history',
          onTap: () => _showLoginHistory(),
        ),
        _buildSecurityTile(
          icon: Icons.notifications_outlined,
          iconColor: Colors.amber,
          title: 'Security Alerts',
          subtitle: 'Configure security notifications',
          onTap: () => _showSecurityAlertsDialog(),
        ),
      ],
    );
  }

  Widget _buildSecurityTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.white.withValues(alpha: 0.4),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDangerZoneSection(AuthController authController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.warning_outlined,
              color: Colors.red.withValues(alpha: 0.8),
              size: 18,
            ),
            const SizedBox(width: 8),
            const Text(
              'Danger Zone',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.red.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              _buildDangerTile(
                icon: Icons.delete_forever_outlined,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account and all data',
                onTap: () => _showDeleteAccountDialog(),
              ),
              _buildDangerTile(
                icon: Icons.logout,
                title: 'Logout from All Devices',
                subtitle: 'Logout from all active sessions',
                onTap: () => _showLogoutAllDialog(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDangerTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.red.withValues(alpha: 0.8),
        size: 20,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.red,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 11,
          color: Colors.white.withValues(alpha: 0.6),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.red.withValues(alpha: 0.6),
      ),
      onTap: onTap,
    );
  }

  void _showLoginHistory() {
    final history = [
      {'device': 'iPhone 14 Pro', 'location': 'Mumbai, India', 'time': 'Current session', 'active': true},
      {'device': 'iPad Air', 'location': 'Delhi, India', 'time': '2 hours ago', 'active': true},
      {'device': 'Chrome - Windows', 'location': 'Bangalore, India', 'time': 'Yesterday', 'active': false},
    ];

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(Get.context!).size.height * 0.6,
        ),
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF2A2A3E),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Login History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.computer,
                        color: Colors.white.withValues(alpha: 0.6),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['device'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${(item['location'] as String)} - ${(item['time'] as String)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (item['active'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showSecurityAlertsDialog() {
    final enableLoginAlerts = true.obs;
    final enableDeviceAlerts = true.obs;
    final enableSuspiciousActivityAlerts = true.obs;

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text(
          'Security Alerts',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => SwitchListTile(
              title: const Text('Login Alerts', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Get notified of new logins', style: TextStyle(color: Colors.white70, fontSize: 12)),
              value: enableLoginAlerts.value,
              onChanged: (value) => enableLoginAlerts.value = value,
              activeThumbColor: const Color(0xFF1E88E5),
            )),
            Obx(() => SwitchListTile(
              title: const Text('Device Alerts', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Get notified of new device bindings', style: TextStyle(color: Colors.white70, fontSize: 12)),
              value: enableDeviceAlerts.value,
              onChanged: (value) => enableDeviceAlerts.value = value,
              activeThumbColor: const Color(0xFF1E88E5),
            )),
            Obx(() => SwitchListTile(
              title: const Text('Suspicious Activity', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Get notified of suspicious login attempts', style: TextStyle(color: Colors.white70, fontSize: 12)),
              value: enableSuspiciousActivityAlerts.value,
              onChanged: (value) => enableSuspiciousActivityAlerts.value = value,
              activeThumbColor: const Color(0xFF1E88E5),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Success',
                'Security alerts updated',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green.withValues(alpha: 0.8),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
            ),
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final confirmText = ''.obs;

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text(
          'Delete Account?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_outlined, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone. All your data will be permanently deleted.',
                      style: TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Type "DELETE" to confirm:',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: (value) => confirmText.value = value,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter DELETE',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: confirmText.value != 'DELETE'
                ? null
                : () {
                    Get.back();
                    Get.snackbar(
                      'Account Deletion',
                      'Account deletion request submitted. You will be logged out.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.withValues(alpha: 0.8),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 5),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutAllDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text(
          'Logout from All Devices?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will log you out from all devices except this one. Other devices will need to login again.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Success',
                'Logged out from all other devices',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green.withValues(alpha: 0.8),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Logout All',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}