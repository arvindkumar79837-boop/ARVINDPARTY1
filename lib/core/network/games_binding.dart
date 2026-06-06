import 'package:get/get.dart';
import '../controllers/mini_games_controller.dart';

class GamesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MiniGamesController>(() => MiniGamesController());
  }
}
