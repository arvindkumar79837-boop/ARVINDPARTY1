// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/routes/features/room_routes.dart
// ARVIND PARTY - ROOM ROUTES
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';

import '../../features/room/presentation/bindings/room_binding.dart';
import '../../features/room/presentation/views/host_controls_screen.dart';
import '../../features/room/presentation/views/moderator_controls_screen.dart';
import '../../features/room/presentation/views/room_analytics_screen.dart';
import '../../features/room/presentation/views/room_background_screen.dart';
import '../../features/room/presentation/views/room_lock_screen.dart';

import '../app_routes.dart';

List<GetPage> get roomRoutes => [
  GetPage(name: AppRoutes.hostControls, page: () => const HostControlsScreen(roomId: ''), binding: RoomBinding()),
  GetPage(name: AppRoutes.moderatorControls, page: () => const ModeratorControlsScreen(), binding: RoomBinding()),
  GetPage(name: AppRoutes.roomLock, page: () => const RoomLockScreen(), binding: RoomBinding()),
  GetPage(name: AppRoutes.roomBackground, page: () => const RoomBackgroundScreen(), binding: RoomBinding()),
  GetPage(name: AppRoutes.roomAnalytics, page: () => const RoomAnalyticsScreen(), binding: RoomBinding()),
];
