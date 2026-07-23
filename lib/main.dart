// ---------------------------------------------------------------------------
// FILE: lib/main.dart
// ARVIND PARTY - ENTRY POINT (Firebase Auth + Node.js Backend)
// ----------------------------------------------------------------------------

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'core/localization/localization_service.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_session_manager.dart';
import 'core/services/feature_flag_service.dart';
import 'core/services/google_play_billing_service.dart';
import 'core/services/livekit_service.dart';
import 'core/socket/socket_service.dart';
import 'core/utils/network_manager.dart';
import 'features/auth/presentation/services/firebase_auth_service.dart';
import 'firebase_options.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch any uncaught Dart async exceptions so the app doesn't silently crash.
  // In production: replace debugPrint with Firebase Crashlytics or Sentry:
  //   FirebaseCrashlytics.instance.recordError(error, stackTrace);
  //   or Sentry.captureException(error, stacktrace: stackTrace);
  runZoned(
    () => _bootstrap(),
    zoneSpecification: ZoneSpecification(
      handleUncaughtError: (zone, delegate, parent, error, stackTrace) {
        debugPrint('═══ UNCAUGHT EXCEPTION ═══');
        debugPrint('$error');
        debugPrint('$stackTrace');
        debugPrint('══════════════════════════');
      },
    ),
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
  Get.put<GooglePlayBillingService>(GooglePlayBillingService(), permanent: true);

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
  bool firebaseInitialized = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Register FirebaseAuthService after Firebase is initialized
    Get.put<FirebaseAuthService>(FirebaseAuthService(), permanent: true);
    firebaseInitialized = true;
  } catch (e) {
    debugPrint('Firebase init failed: $e — will retry on next network event');
    // Schedule a retry when network becomes available
    _scheduleFirebaseRetry();
  }

  // GetStorage does not depend on Firebase, so initialize regardless.
  try {
    await GetStorage.init();
  } catch (e) {
    debugPrint('═══ GetStorage init error ═══');
    debugPrint('Error: $e');
  }

  // Register services that depend on GetStorage (after it's initialized)
  Get.put<LocalizationService>(LocalizationService(), permanent: true);
  Get.put<FeatureFlagService>(FeatureFlagService(), permanent: true);
  Get.put<LiveKitService>(LiveKitService(), permanent: true);
}

/// Retry Firebase initialization when network returns.
/// Maximum 3 retries with exponential backoff (5s, 15s, 30s).
void _scheduleFirebaseRetry() async {
  const delays = [5, 15, 30];
  for (final seconds in delays) {
    await Future.delayed(Duration(seconds: seconds));
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      Get.put<FirebaseAuthService>(FirebaseAuthService(), permanent: true);
      debugPrint('Firebase retry succeeded after ${seconds}s');
      return;
    } catch (e) {
      debugPrint('Firebase retry failed ($e), will try again...');
    }
  }
  debugPrint('Firebase init failed after all retries — running without Firebase');
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
