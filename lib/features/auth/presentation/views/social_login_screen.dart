// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/auth/presentation/views/social_login_screen.dart
// ARVIND PARTY - SOCIAL LOGIN SCREEN (Google, Apple, Facebook)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../controllers/login_controller.dart';

class SocialLoginScreen extends StatelessWidget {
  const SocialLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.find<LoginController>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  _buildLogo(),
                  const SizedBox(height: 16),
                  const Text(
                    'Quick Login',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose your preferred sign-in method',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 3),
                  _buildSocialButtons(controller),
                  const SizedBox(height: 40),
                  _buildGuestOption(controller),
                  const SizedBox(height: 24),
                  _buildBackButton(context),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
          Obx(() => controller.isLoading.value
              ? _buildLoadingOverlay(controller)
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.3),
          radius: 1.2,
          colors: [Color(0xFF3E2723), Color(0xFF1A1A1A), Color(0xFF000000)],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha: 0.3),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3), width: 1.5),
      ),
      child: const Icon(
        Icons.pets,
        color: Color(0xFFFFC107),
        size: 48,
      ),
    );
  }

  Widget _buildSocialButtons(LoginController controller) {
    return Column(
      children: [
        _SocialLoginButton(
          label: 'Continue with Google',
          icon: FontAwesomeIcons.google,
          iconColor: const Color(0xFF4285F4),
          backgroundColor: Colors.white,
          textColor: Colors.black87,
          onTap: controller.loginWithGoogle,
        ),
        const SizedBox(height: 16),
        _SocialLoginButton(
          label: 'Continue with Apple',
          icon: FontAwesomeIcons.apple,
          iconColor: Colors.white,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          onTap: controller.loginWithApple,
        ),
        const SizedBox(height: 16),
        _SocialLoginButton(
          label: 'Continue with Facebook',
          icon: FontAwesomeIcons.facebook,
          iconColor: const Color(0xFF1877F2),
          backgroundColor: const Color(0xFF1877F2),
          textColor: Colors.white,
          onTap: controller.loginWithFacebook,
        ),
      ],
    );
  }

  Widget _buildGuestOption(LoginController controller) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(color: Colors.white.withValues(alpha: 0.3)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              ),
            ),
            Expanded(
              child: Divider(color: Colors.white.withValues(alpha: 0.3)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: controller.continueAsGuest,
          icon: const Icon(Icons.person_outline, color: Colors.white70),
          label: const Text(
            'Continue as Guest',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () => Get.back(),
      icon: const Icon(Icons.arrow_back, color: Colors.white70, size: 18),
      label: const Text(
        'Back to Login',
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  Widget _buildLoadingOverlay(LoginController controller) {
    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFF1E88E5),
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Obx(() => Text(
                    controller.loadingMessage.value,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  const _SocialLoginButton({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
          backgroundColor: backgroundColor.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}