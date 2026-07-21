import 'package:get/get.dart';
import '../controllers/singing_room_controller.dart';

class SingingRoomBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SingingRoomController>(() => SingingRoomController());
  }
}
