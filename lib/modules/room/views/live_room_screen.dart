import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/live_room_controller.dart';
import '../models/room_models.dart';

class LiveRoomScreen extends StatelessWidget {
  final Map<String, dynamic> room;
  late final LiveRoomController controller;
  final TextEditingController chatController = TextEditingController();

  LiveRoomScreen({super.key, required this.room}) {
    // Initialize the real-time socket controller for this specific room
    controller = Get.put(
        LiveRoomController(roomId: room['_id'] ?? room['id'] ?? 'unknown'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Opacity(
                opacity: 0.3,
                child: CachedNetworkImage(
                  imageUrl:
                      room['coverImage'] ?? 'https://via.placeholder.com/400',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Column(
              children: [
                _buildRoomHeader(),
                const SizedBox(height: 20),
                _buildMicSeats(),
                const Spacer(),
                _buildChatList(),
                _buildBottomControls(context),
              ],
            ),

            // Connection Status Overlay
            Obx(() => controller.isConnected.value
                ? const SizedBox.shrink()
                : const Center(
                    child: CircularProgressIndicator(color: Colors.amber))),

            // Real-time Gift Animation Overlay
            _buildGiftAnimationOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(room['ownerId']
                    ?['avatar'] ??
                'https://via.placeholder.com/150'),
            radius: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(room['name'] ?? 'Voice Room',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Text('ID: ${room['roomId'] ?? '10000'}',
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: Colors.black54, borderRadius: BorderRadius.circular(20)),
            child: const Row(
              children: [
                Icon(Icons.people, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text('Live',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMicSeats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.8,
        ),
        itemCount: 8, // Displaying 8 seats for the UI
        itemBuilder: (context, index) {
          return Obx(() {
            // Find if anyone is sitting in this specific seat index
            final seat =
                controller.seats.firstWhereOrNull((s) => s.seatIndex == index);

            return GestureDetector(
              onTap: () {
                if (seat == null || seat.userId == null) {
                  controller.claimSeat(index);
                }
              },
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white10,
                    backgroundImage: seat?.userAvatar != null
                        ? CachedNetworkImageProvider(seat!.userAvatar!)
                        : null,
                    child: seat?.userId == null
                        ? const Icon(Icons.add, color: Colors.white38)
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    seat?.userName ?? 'Seat ${index + 1}',
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildChatList() {
    return Container(
      height: 250,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Obx(() => ListView.builder(
            reverse: true, // Auto-scroll to bottom
            itemCount: controller.messages.length,
            itemBuilder: (context, index) {
              final msg = controller.messages[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${msg.senderName}: ',
                        style: const TextStyle(
                            color: Colors.amber, fontWeight: FontWeight.bold)),
                    Expanded(
                        child: Text(msg.message,
                            style: const TextStyle(color: Colors.white))),
                  ],
                ),
              );
            },
          )),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: chatController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Say something...',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white10,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (text) {
                controller.sendMessage(text);
                chatController.clear();
              },
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => IconButton(
                icon: Icon(
                  controller.isMicMuted.value ? Icons.mic_off : Icons.mic,
                  color: controller.isMicMuted.value
                      ? Colors.redAccent
                      : Colors.white,
                ),
                onPressed: controller.toggleMic,
              )),
          IconButton(
            icon: const Icon(Icons.card_giftcard, color: Colors.pinkAccent),
            onPressed: () {
              // Open the beautiful Gift BottomSheet UI
              _showGiftBottomSheet(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGiftAnimationOverlay() {
    return Obx(() {
      final gift = controller.currentGift.value;
      if (gift == null) return const SizedBox.shrink();

      // Using Future.delayed to clear the gift from UI after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (controller.currentGift.value == gift) {
          controller.currentGift.value = null;
        }
      });

      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CachedNetworkImage(
              imageUrl: gift.giftImageUrl,
              height: 200,
              width: 200,
              errorWidget: (context, url, error) => const Icon(
                  Icons.card_giftcard,
                  size: 100,
                  color: Colors.pink),
            ),
            const SizedBox(height: 10),
            Text('${gift.senderName} sent a Gift! x${gift.quantity}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.pink, blurRadius: 10)])),
          ],
        ),
      );
    });
  }

  void _showGiftBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF1E1E1E),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            height: 350,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Send a Gift',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Expanded(
                  child: Obx(() {
                    if (controller.availableGifts.isEmpty) {
                      return const Center(
                          child: Text('No gifts available.',
                              style: TextStyle(color: Colors.white54)));
                    }
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: controller.availableGifts.length,
                      itemBuilder: (context, index) {
                        final gift = controller.availableGifts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context); // Close BottomSheet
                            final receiverId = room['ownerId']?['_id'] ??
                                room['ownerId']?['userId'] ??
                                'unknown';
                            controller.sendGift(
                                receiverId, gift['_id'] as String,
                                quantity: 1);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: gift['iconUrl'] ?? '',
                                  height: 40,
                                  width: 40,
                                  errorWidget: (c, u, e) => const Text('🎁',
                                      style: TextStyle(fontSize: 32)),
                                ),
                                const SizedBox(height: 4),
                                Text(gift['name'] as String,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.diamond,
                                        color: Colors.cyanAccent, size: 12),
                                    const SizedBox(width: 2),
                                    Text('${gift['price']}',
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12)),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          );
        });
  }
}
