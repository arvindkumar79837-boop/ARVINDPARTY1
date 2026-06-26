import 'package:get/get.dart';
import '../controllers/youtube_controller.dart';
import '../repositories/youtube_repository.dart';

class YouTubeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<YouTubeRepository>(() => YouTubeRepository());
    Get.lazyPut<YouTubeController>(() => YouTubeController(
      roomId: Get.arguments?['roomId'],
      hostId: Get.arguments?['userId'],
      currentUserId: Get.arguments?['userId'],
      isHost: Get.arguments?['isHost'] ?? false,
    ));
  }
}
