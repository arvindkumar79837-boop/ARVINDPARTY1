// ---------------------------------------------------------------------------
// FILE: lib/main.dart
// ARVIND PARTY - ENTRY POINT (Firebase Auth + Node.js Backend)
// ----------------------------------------------------------------------------

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'core/services/api_service.dart';
import 'core/services/auth_session_manager.dart';
import 'core/socket/socket_service.dart';
import 'core/utils/network_manager.dart';
import 'firebase_options.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch any uncaught Dart async exceptions so the app doesn't silently crash.
  // Errors are logged to console for debugging; in production, replace with
  // a crash reporting service (e.g. Sentry).
  runZonedGuarded(
    () => _bootstrap(),
    (error, stackTrace) {
      debugPrint('═══ UNCAUGHT EXCEPTION ═══');
      debugPrint('$error');
      debugPrint('$stackTrace');
      debugPrint('══════════════════════════');
    },
  );
}

Future<void> _bootstrap() async {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugPrint('FlutterError: ${details.exception}\n${details.stack}');
    return Material(
      color: const Color(0xFF0F0E17),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Something went wrong',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  };

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ═══════════════════════════════════════════════════════════════════════
  // ORDERED SERVICE REGISTRATION (dependency chain, not alphabetical!)
  // ═══════════════════════════════════════════════════════════════════════
  //
  // Dependency graph:
  //   AuthSessionManager.onInit() → Get.find<ApiService>()
  //   SocketService.onInit()      → Get.find<AuthSessionManager>()
  //   ApiService.onInit()         → safe (Dio interceptor is deferred)
  //
  // Correct order: ApiService → AuthSessionManager → SocketService
  // ═══════════════════════════════════════════════════════════════════════
  Get.put<ApiService>(ApiService(), permanent: true);
  Get.put<AuthSessionManager>(AuthSessionManager(), permanent: true);
  Get.put<SocketService>(SocketService(), permanent: true);
  Get.put<NetworkManager>(NetworkManager(), permanent: true);

  // Initialize all asynchronous services FIRST before running the app
  // This prevents race conditions where services are accessed before they're ready
  await initAsynchronousServices();

  runApp(const ArvindPartyApp());
}

// This function initializes all heavy backend services
Future<void> initAsynchronousServices() async {
  // ── Step 1: Firebase & Storage ─────────────────────────────────────────
  // Firebase.initializeApp() internally triggers FirebaseInstallations which
  // throws 'SERVICE_NOT_AVAILABLE' on network failures. Must be try-caught
  // so the app can still boot and navigate to the login screen.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Non-fatal — the app continues without Firebase. FCM token registration
    // will be retried later when network is available.
  }

  // GetStorage does not depend on Firebase, so initialize regardless.
  try {
    await GetStorage.init();
  } catch (e) {
  }
}

class ArvindPartyApp extends StatelessWidget {
  const ArvindPartyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ARVIND PARTY',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0E17),
        primaryColor: const Color(0xFFFF8906),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF8906),
          secondary: Color(0xFFFFC107),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF15141F),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
        ),
      ),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
