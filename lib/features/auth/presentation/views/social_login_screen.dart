import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../controllers/login_controller.dart';

class SocialLoginScreen extends StatefulWidget {
  const SocialLoginScreen({super.key});

  @override
  State<SocialLoginScreen> createState() => _SocialLoginScreenState();
}

class _SocialLoginScreenState extends State<SocialLoginScreen> {
  late VideoPlayerController _videoController;
  bool _videoInitialized = false;

  final LoginController controller = Get.find<LoginController>();

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() {
    _videoController = VideoPlayerController.asset('assets/login/videos/lion_bg.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _videoInitialized = true);
          _videoController
            ..setLooping(true)
            ..setVolume(0.0)
            ..play();
        }
      }).catchError((e) {
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildBackground(size),
          _buildGradientOverlay(),
          SafeArea(child: _buildContent(context, size)),
          Obx(() => controller.isLoading.value ? _buildLoadingOverlay() : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildBackground(Size size) {
    if (_videoInitialized && _videoController.value.isInitialized) {
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _videoController.value.size.width,
            height: _videoController.value.size.height,
            child: VideoPlayer(_videoController),
          ),
        ),
      );
    }
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.3),
          radius: 1.2,
          colors: [Color(0xFF3E2723), Color(0xFF1A1A1A), Color(0xFF000000)],
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.35, 0.6, 1.0],
          colors: [Color(0x99000000), Color(0x22000000), Color(0xBB000000), Color(0xEE000000)],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Size size) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: size.height),
        child: Column(
          children: [
            SizedBox(height: size.height * 0.06),
            _buildHeader(size),
            SizedBox(height: size.height * 0.08),
            _buildSocialButtons(),
            const SizedBox(height: 24),
            _buildTermsSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.3),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
          ),
          child: Image.asset(
            'assets/login/login_icon.png',
            width: 48,
            height: 48,
            errorBuilder: (_, __, ___) => const Icon(Icons.pets, color: Color(0xFFFFC107), size: 40),
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Arvind\n',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white, height: 1.1, shadows: [Shadow(color: Colors.black54, blurRadius: 8)]),
              ),
              TextSpan(
                text: 'Party',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 26, fontWeight: FontWeight.w600, color: Color(0xFFFFC107), shadows: [Shadow(color: Colors.black54, blurRadius: 8)]),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildSocialButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildSocialButton(
            label: 'Continue with Google',
            icon: Icons.g_mobiledata,
            color: Colors.white,
            textColor: Colors.black87,
            onTap: controller.loginWithGoogle,
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.3, end: 0),
          const SizedBox(height: 12),
          _buildSocialButton(
            label: 'Continue with Phone Number',
            icon: Icons.phone_android,
            color: Colors.white.withValues(alpha: 0.1),
            textColor: Colors.white,
            isOutlined: true,
            onTap: controller.goToPhoneAuth,
          ).animate().fadeIn(delay: 900.ms, duration: 600.ms).slideY(begin: 0.3, end: 0),
          const SizedBox(height: 12),
          _buildSocialButton(
            label: 'Continue as Guest',
            icon: Icons.person_outline,
            color: Colors.white.withValues(alpha: 0.05),
            textColor: Colors.white70,
            isOutlined: true,
            onTap: controller.continueAsGuest,
          ).animate().fadeIn(delay: 1000.ms, duration: 600.ms).slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    bool isOutlined = false,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: isOutlined ? Colors.white54 : Colors.transparent, width: 1.5),
          backgroundColor: color,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsSection() {
    return Obx(() => GestureDetector(
      onTap: controller.toggleTerms,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20, height: 20,
              decoration: BoxDecoration(
                color: controller.isTermsAccepted.value ? const Color(0xFF1E88E5) : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: controller.isTermsAccepted.value ? const Color(0xFF1E88E5) : Colors.white54, width: 2),
              ),
              child: controller.isTermsAccepted.value ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12.5, fontFamily: 'Poppins'),
                  children: const [
                    TextSpan(text: 'Agree to '),
                    TextSpan(text: 'Terms of Service', style: TextStyle(color: Color(0xFF64B5F6), decoration: TextDecoration.underline)),
                    TextSpan(text: ' and '),
                    TextSpan(text: 'Privacy Policy', style: TextStyle(color: Color(0xFF64B5F6), decoration: TextDecoration.underline)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    )).animate().fadeIn(delay: 1100.ms, duration: 600.ms);
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF1E88E5), strokeWidth: 3),
              const SizedBox(height: 16),
              Obx(() => Text(controller.loadingMessage.value, style: const TextStyle(color: Colors.white70, fontSize: 14))),
            ],
          ),
        ),
      ),
    );
  }
}