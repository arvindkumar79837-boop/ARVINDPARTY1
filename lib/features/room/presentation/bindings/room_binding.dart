// Box drawing header
// FILE: room_binding.dart

import 'package:get/get.dart';

import '../controllers/live_room_controller.dart';
import '../controllers/room_controller.dart';
import '../controllers/room_settings_controller.dart';

class RoomBinding extends Bindings {
  final String roomId;
  final String roomOwnerId;
  final bool useLiveController;
  RoomBinding({this.roomId = '', this.roomOwnerId = '', this.useLiveController = false});

  @override
  void dependencies() {
    if (useLiveController) {
      Get.lazyPut<LiveRoomController>(() => LiveRoomController(
        roomId: roomId,
        roomOwnerId: roomOwnerId,
      ));
    } else {
      Get.lazyPut<RoomController>(() => RoomController(roomId: roomId, roomOwnerId: roomOwnerId));
    }

    // Room settings controller for room configuration widgets
    Get.lazyPut<RoomSettingsController>(() => RoomSettingsController());
  }
}
