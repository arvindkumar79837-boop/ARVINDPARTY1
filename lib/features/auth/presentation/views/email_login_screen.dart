// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/auth/presentation/views/email_login_screen.dart
// ARVIND PARTY - EMAIL LOGIN SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class EmailLoginScreen extends StatelessWidget {
  const EmailLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
          key: controller.authFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in with your email',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 40),
                _buildEmailField(controller),
                const SizedBox(height: 20),
                _buildPasswordField(controller),
                const SizedBox(height: 16),
                _buildForgotPasswordLink(controller),
                const SizedBox(height: 32),
                _buildLoginButton(controller),
                const SizedBox(height: 20),
                _buildSocialLoginRow(context, controller),
                const SizedBox(height: 24),
                _buildSignupLink(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField(LoginController controller) {
    return TextFormField(
      controller: controller.emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Enter your email',
        prefixIcon: const Icon(Icons.email, color: Color(0xFF64B5F6)),
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E88E5)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email is required';
        }
        if (!GetUtils.isEmail(value)) {
          return 'Enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(LoginController controller) {
    return Obx(() => TextFormField(
          controller: controller.passwordController,
          obscureText: controller.passwordController.text.isNotEmpty,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter your password',
            prefixIcon: const Icon(Icons.lock, color: Color(0xFF64B5F6)),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.visibility_off,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              onPressed: () {
                controller.obscurePassword.value = !controller.obscurePassword.value;
              },
            ),
            labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E88E5)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password is required';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ));
  }

  Widget _buildForgotPasswordLink(LoginController controller) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => controller.goToPasswordReset(),
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            color: Color(0xFF64B5F6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(LoginController controller) {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.submitEmailLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              disabledBackgroundColor: const Color(0xFF1E88E5).withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ));
  }

  Widget _buildSocialLoginRow(BuildContext context, LoginController controller) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: Colors.white.withValues(alpha: 0.3)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or login with',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          ),
        ),
        Expanded(
          child: Divider(color: Colors.white.withValues(alpha: 0.3)),
        ),
      ],
    );
  }

  Widget _buildSignupLink(LoginController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
        TextButton(
          onPressed: () => controller.goToSignup(),
          child: const Text(
            'Sign Up',
            style: TextStyle(
              color: Color(0xFF64B5F6),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}