// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/media/presentation/bindings/media_binding.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../controllers/media_player_controller.dart';

class MediaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MediaPlayerController>(() => MediaPlayerController());
  }
}