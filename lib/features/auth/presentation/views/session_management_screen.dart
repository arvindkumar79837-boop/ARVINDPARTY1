// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/auth/presentation/views/session_management_screen.dart
// ARVIND PARTY - SESSION MANAGEMENT SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/auth_controller.dart';

class SessionManagementScreen extends StatelessWidget {
  const SessionManagementScreen({super.key});

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
          'Session Management',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCurrentSessionCard(authController, storage),
            const SizedBox(height: 24),
            _buildSessionInfoCard(authController, storage),
            const SizedBox(height: 24),
            _buildSecurityTipsCard(),
            const SizedBox(height: 24),
            _buildLogoutButton(authController),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSessionCard(AuthController authController, GetStorage storage) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E88E5).withValues(alpha: 0.15),
            const Color(0xFF1E88E5).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1E88E5).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.security_outlined,
                color: Color(0xFF64B5F6),
                size: 24,
              ),
              SizedBox(width: 10),
              Text(
                'Current Session',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSessionRow(
            icon: Icons.person_outline,
            label: 'User',
            value: authController.currentUser.value?.username ?? 'Guest',
          ),
          const SizedBox(height: 12),
          _buildSessionRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: authController.currentUser.value?.phone ?? storage.read('phone') ?? 'Not set',
          ),
          const SizedBox(height: 12),
          _buildSessionRow(
            icon: Icons.verified_user,
            label: 'Status',
            value: authController.isLoggedIn.value ? 'Active' : 'Inactive',
            valueColor: authController.isLoggedIn.value ? Colors.green : Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildSessionRow(
            icon: Icons.access_time,
            label: 'Login Time',
            value: _getLoginTime(storage),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64B5F6)),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: valueColor ?? Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildSessionInfoCard(AuthController authController, GetStorage storage) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Color(0xFF64B5F6),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Session Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            label: 'Token Type',
            value: 'Bearer Token',
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            label: 'Session Storage',
            value: 'Local (GetStorage)',
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            label: 'Auto Refresh',
            value: 'Enabled',
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            label: 'Last Activity',
            value: 'Just now',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityTipsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.1),
            Colors.orange.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.security_outlined,
                color: Colors.orange,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Security Tips',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTipRow(
            icon: Icons.check_circle_outline,
            text: 'Never share your OTP with anyone',
          ),
          const SizedBox(height: 10),
          _buildTipRow(
            icon: Icons.check_circle_outline,
            text: 'Log out from shared devices',
          ),
          const SizedBox(height: 10),
          _buildTipRow(
            icon: Icons.check_circle_outline,
            text: 'Keep your device binding up to date',
          ),
          const SizedBox(height: 10),
          _buildTipRow(
            icon: Icons.check_circle_outline,
            text: 'Report suspicious activity immediately',
          ),
        ],
      ),
    );
  }

  Widget _buildTipRow({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.orange.withValues(alpha: 0.8),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(AuthController authController) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutConfirmDialog(authController),
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmDialog(AuthController authController) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text(
          'Logout?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to logout? You will need to login again to access your account.',
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
              authController.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _getLoginTime(GetStorage storage) {
    try {
      final loginTimeStr = storage.read('login_time');
      if (loginTimeStr != null) {
        final loginTime = DateTime.parse(loginTimeStr);
        final now = DateTime.now();
        final diff = now.difference(loginTime);

        if (diff.inMinutes < 1) return 'Just now';
        if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
        if (diff.inHours < 24) return '${diff.inHours} hours ago';
        return '${diff.inDays} days ago';
      }
    } catch (e) { /* empty */ }
    return 'Unknown';
  }
}