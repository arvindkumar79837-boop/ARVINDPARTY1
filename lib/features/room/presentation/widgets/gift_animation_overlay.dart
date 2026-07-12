import 'package:arvind_party/features/room/presentation/controllers/live_room_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GiftAnimationOverlay extends GetView<LiveRoomController> {
  const GiftAnimationOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final gift = controller.activeGiftAnimation.value;
      if (gift == null) {
        return const SizedBox.shrink();
      }

      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.scale(
              scale: value,
              child: child,
            ),
          );
        },
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${gift.senderName} sent a',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 16),
                Image.network(
                  gift.giftImageUrl ?? '',
                  width: 100,
                  height: 100,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.cake,
                    color: Colors.pink,
                    size: 100,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  gift.giftName,
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (gift.quantity > 1)
                  Text(
                    'x${gift.quantity}',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
