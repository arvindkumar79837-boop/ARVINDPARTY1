// ---------------------------------------------------------------------------
// FILE: lib/main.dart
// ARVIND PARTY - ENTRY POINT (Firebase Auth + Node.js Backend)
// ----------------------------------------------------------------------------

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'core/localization/localization_service.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_session_manager.dart';
import 'core/socket/socket_service.dart';
import 'core/utils/network_manager.dart';
import 'features/auth/presentation/repositories/auth_repository.dart';
import 'features/chat/presentation/repositories/chat_repository.dart';
import 'features/gift/presentation/repositories/gift_repository.dart';
import 'features/home/services/user_repository.dart';
import 'features/room/presentation/repositories/room_repository.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  // Initialize all asynchronous services FIRST before running the app
  // This prevents race conditions where services are accessed before they're ready
  await initAsynchronousServices();

  runApp(const ArvindPartyApp());
}

// This function initializes all heavy backend services
Future<void> initAsynchronousServices() async {
  try {
    await Firebase.initializeApp();
    await GetStorage.init();

    // --- CORE SERVICES (Permanent) ------------------------------------
    Get.put<ApiService>(ApiService(), permanent: true);
    Get.put<SocketService>(SocketService(), permanent: true);
    Get.put<AuthSessionManager>(AuthSessionManager(), permanent: true);

    // --- REPOSITORIES (Permanent) -------------------------------------
    Get.put<NetworkManager>(NetworkManager(), permanent: true);
    Get.put<AuthRepository>(AuthRepository(), permanent: true);
    Get.put<UserRepository>(UserRepository(), permanent: true);
    Get.put<RoomRepository>(RoomRepository(), permanent: true);
    Get.put<ChatRepository>(ChatRepository(), permanent: true);
    Get.put<GiftRepository>(GiftRepository(), permanent: true);

    Get.put<LocalizationService>(LocalizationService(), permanent: true);

    debugPrint('?? [Arvind Party] ???? ?????? ???????? ??????????? ??? ?? ???!');
  } catch (e) {
    debugPrint('?? ???????? ??? ???? ??? ?????? ??: $e');
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
