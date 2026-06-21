// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/games/presentation/bindings/games_binding.dart
// ARVIND PARTY - GAMES BINDING
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../controllers/games_controller.dart';

class GamesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GamesController>(() => GamesController());
  }
}