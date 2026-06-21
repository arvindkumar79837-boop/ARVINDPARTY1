// ═══════════════════════════════════════════════════════════════════════════
// WEB APP PAGES
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../core/constants/auth_controller.dart';
import '../core/theme/web_theme.dart';
import '../modules/dashboard/dashboard_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: BindingsBuilder(() {
        Get.put<AuthController>(AuthController(), permanent: true);
      }),
    ),
  ];
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final authController = Get.put(AuthController());

    return Scaffold(
      backgroundColor: WebTheme.backgroundDark,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: WebTheme.backgroundLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.admin_panel_settings, size: 64, color: WebTheme.primaryOrange),
              const SizedBox(height: 24),
              const Text('Admin Panel', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: WebTheme.textPrimary)),
              const SizedBox(height: 32),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
              Obx(() => ElevatedButton(
                onPressed: authController.isLoading.value ? null : () async {
                  final success = await authController.login(
                    usernameController.text,
                    passwordController.text,
                  );
                  if (success) {
                    Get.offAllNamed(AppRoutes.dashboard);
                  } else {
                    Get.snackbar('Error', authController.errorMessage.value);
                  }
                },
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                child: authController.isLoading.value
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Text('Login'),
              )),
            ],
          ),
        ),
      ),
    );
  }
}