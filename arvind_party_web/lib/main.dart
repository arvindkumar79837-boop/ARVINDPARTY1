import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/constants/auth_controller.dart';
import 'core/network/admin_api.dart';
import 'core/theme/web_theme.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

// ============================================================
// ARVIND PARTY WEB — Admin Panel Entry Point
// ============================================================

// Securely define Firebase options using compile-time variables.
// These values are passed during the build command, e.g.:
// flutter run -d chrome --dart-define=FIREBASE_API_KEY=YOUR_KEY
const firebaseOptions = FirebaseOptions(
  apiKey: String.fromEnvironment('FIREBASE_API_KEY', defaultValue: 'NOT_SET'),
  authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN', defaultValue: 'NOT_SET'),
  projectId: String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: 'NOT_SET'),
  storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET', defaultValue: 'NOT_SET'),
  messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: 'NOT_SET'),
  appId: String.fromEnvironment('FIREBASE_APP_ID', defaultValue: 'NOT_SET'),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
  ]);
  
  await GetStorage.init();

  // Initialize Firebase securely using the compile-time options.
  await Firebase.initializeApp(options: firebaseOptions);

  Get.put<AdminApi>(AdminApi(), permanent: true);
  Get.put<AuthController>(AuthController(), permanent: true);

  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Arvind Party Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: WebTheme.darkTheme,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
      initialRoute: AppRoutes.login,
      getPages: AppPages.pages,
      unknownRoute: GetPage(
        name: '/not-found',
        page: () => const _NotFoundPage(),
        transition: Transition.fadeIn,
      ),
      routingCallback: (routing) {
        final auth = AuthController.to;
        if (routing?.current == AppRoutes.login && auth.isLoggedIn.value) {
          Get.offAllNamed(AppRoutes.dashboard);
        }
      },
    );
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WebTheme.backgroundDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: WebTheme.errorRed),
            const SizedBox(height: 16),
            Text('404', style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: WebTheme.errorRed, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Page Not Found', style: TextStyle(color: WebTheme.textSecondary, fontSize: 18)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Get.offAllNamed(AppRoutes.login),
              icon: const Icon(Icons.home),
              label: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}