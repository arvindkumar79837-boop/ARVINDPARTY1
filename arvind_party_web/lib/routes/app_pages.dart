// ═══════════════════════════════════════════════════════════════════════════
// WEB APP PAGES
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../core/constants/auth_controller.dart';
import '../core/theme/web_theme.dart';
import '../modules/dashboard/dashboard_view.dart';
import '../modules/vip/views/vip_admin_view.dart';
import '../modules/family_management/family_management_view.dart';
import '../modules/security/security_dashboard_view.dart';
import '../modules/security/security_binding.dart';
import '../modules/events/event_management_view.dart';
import '../modules/events/lucky_draw_management_view.dart';
import '../modules/events/daily_task_management_view.dart';
import '../modules/events/invite_management_view.dart';
import '../modules/events/login_streak_management_view.dart';
import '../modules/analytics/views/analytics_dashboard_view.dart';
import '../modules/analytics/bindings/analytics_binding.dart';
import '../modules/localization/localization_management_view.dart';
import '../modules/wallets/wallet_management_view.dart';
import '../modules/pk_battle/pk_battle_management_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: AppRoutes.localization,
      page: () => const LocalizationManagementView(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: BindingsBuilder(() {
        Get.put<AuthController>(AuthController(), permanent: true);
      }),
    ),
    GetPage(
      name: AppRoutes.securityDashboard,
      page: () => const SecurityDashboardView(),
      binding: SecurityBinding(),
    ),
    GetPage(
      name: AppRoutes.vipAdmin,
      page: () => const VipAdminView(),
    ),
    GetPage(
      name: AppRoutes.families,
      page: () => const FamilyManagementView(),
    ),
    GetPage(
      name: AppRoutes.events,
      page: () => const EventManagementView(),
    ),
    GetPage(
      name: AppRoutes.luckyDraws,
      page: () => const LuckyDrawManagementView(),
    ),
    GetPage(
      name: AppRoutes.dailyTasks,
      page: () => const DailyTaskManagementView(),
    ),
    GetPage(
      name: AppRoutes.invites,
      page: () => const InviteManagementView(),
    ),
    GetPage(
      name: AppRoutes.loginStreaks,
      page: () => const LoginStreakManagementView(),
    ),
    GetPage(
      name: AppRoutes.analyticsDashboard,
      page: () => const AnalyticsDashboardView(),
      binding: AnalyticsBinding(),
    ),
    GetPage(
      name: AppRoutes.walletManagement,
      page: () => const WalletManagementView(),
    ),
    GetPage(
      name: AppRoutes.pkBattleManagement,
      page: () => PkBattleManagementView(),
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