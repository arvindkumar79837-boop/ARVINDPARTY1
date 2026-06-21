// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/room/widgets/room_card.dart
// ARVIND PARTY - ROOM CARD WIDGET (List item with type badge)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/room_models.dart';
import '../controllers/room_controller.dart';

class RoomCard extends StatelessWidget {
  final RoomModel room;
  final RoomController controller = Get.find<RoomController>();

  RoomCard({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final typeLabel = room.roomType ?? 'room';
    final hasPassword = (room.password ?? room.roomPassword ?? '').isNotEmpty;

    return GestureDetector(
      onTap: () => Get.toNamed('/room-detail', arguments: {'roomId': room.id}),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  typeLabel[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(room.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(typeLabel, style: const TextStyle(color: Colors.blue, fontSize: 10)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${room.currentMembers} members • ${room.seatCount} seats',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            if (hasPassword)
              const Icon(Icons.lock, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }
}