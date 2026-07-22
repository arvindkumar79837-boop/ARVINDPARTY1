import 'package:get/get.dart';

import '../controllers/room_features_controller.dart';

class RoomFeaturesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RoomFeaturesController>(() => RoomFeaturesController());
  }
}
