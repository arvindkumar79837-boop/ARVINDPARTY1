// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/routes/features/auth_routes.dart
// ARVIND PARTY - AUTH ROUTES
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';

import '../../features/auth/presentation/bindings/auth_binding.dart';
import '../../features/auth/presentation/views/account_security_screen.dart';
import '../../features/auth/presentation/views/device_binding_screen.dart';
import '../../features/auth/presentation/views/email_login_screen.dart';
import '../../features/auth/presentation/views/login_screen.dart';
import '../../features/auth/presentation/views/multi_device_control_screen.dart';
import '../../features/auth/presentation/views/otp_screen.dart';
import '../../features/auth/presentation/views/password_reset_screen.dart';
import '../../features/auth/presentation/views/phone_auth_screen.dart';
import '../../features/auth/presentation/views/session_management_screen.dart';
import '../../features/auth/presentation/views/signup_screen.dart';
import '../../features/auth/presentation/views/social_login_screen.dart';

import '../app_routes.dart';

List<GetPage> get authRoutes => [
  GetPage(name: AppRoutes.login, page: () => const LoginScreen(), binding: AuthBinding()),
  GetPage(name: AppRoutes.signup, page: () => const SignupScreen(), binding: AuthBinding()),
  GetPage(name: AppRoutes.phoneAuth, page: () => const PhoneAuthScreen(), binding: AuthBinding()),
  GetPage(name: AppRoutes.otp, page: () => const OtpScreen(), binding: AuthBinding()),
  GetPage(name: AppRoutes.emailLogin, page: () => const EmailLoginScreen(), binding: AuthBinding()),
  GetPage(name: AppRoutes.googleLogin, page: () => const SocialLoginScreen(), binding: AuthBinding()),
  GetPage(name: AppRoutes.passwordReset, page: () => const PasswordResetScreen(), binding: AuthBinding()),
  GetPage(name: AppRoutes.deviceBinding, page: () => const DeviceBindingScreen(), binding: AuthBinding()),
  GetPage(name: AppRoutes.multiDeviceControl, page: () => const MultiDeviceControlScreen(), binding: AuthBinding()),
  GetPage(name: AppRoutes.sessionManagement, page: () => const SessionManagementScreen(), binding: AuthBinding()),
  GetPage(name: AppRoutes.accountSecurity, page: () => const AccountSecurityScreen(), binding: AuthBinding()),
];
