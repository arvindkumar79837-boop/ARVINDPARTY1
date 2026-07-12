import 'package:arvind_party/features/room/models/room_models.dart';
import 'package:arvind_party/features/room/presentation/controllers/live_room_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SeatGrid extends GetView<LiveRoomController> {
  const SeatGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(
        () => GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.seatCount.value,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final seat = controller.seats.firstWhere(
              (s) => s.index == index,
              orElse: () => SeatData(seatIndex: index), // Should not happen
            );

            return GestureDetector(
              onTap: () {
                if (!seat.isOccupied) {
                  controller.joinSeat(index);
                }
              },
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: seat.isLocked ? Colors.grey.withOpacity(0.3) : Colors.white.withOpacity(0.1),
                        backgroundImage: seat.isOccupied && seat.userAvatar != null
                            ? NetworkImage(seat.userAvatar!)
                            : null,
                        child: !seat.isOccupied
                            ? Icon(
                                seat.isLocked ? Icons.lock : Icons.add,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      if (seat.isMuted)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.mic_off, color: Colors.red, size: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    seat.userName ?? 'Empty',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
