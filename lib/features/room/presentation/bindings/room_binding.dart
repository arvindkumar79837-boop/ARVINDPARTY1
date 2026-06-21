// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/room/bindings/room_binding.dart
// ARVIND PARTY - ROOM BINDING
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../controllers/room_controller.dart';

class RoomBinding extends Bindings {
  final String roomId;
  final String roomOwnerId;
  RoomBinding({this.roomId = '', this.roomOwnerId = ''});

  @override
  void dependencies() {
    Get.lazyPut<RoomController>(() => RoomController(roomId: roomId, roomOwnerId: roomOwnerId));
  }
}
