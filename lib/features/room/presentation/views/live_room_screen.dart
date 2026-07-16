// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/room/presentation/views/live_room_screen.dart
// ARVIND PARTY - LIVE ROOM SCREEN (REBUILT WITH FULL UI & GetX)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:arvind_party/features/room/presentation/controllers/live_room_controller.dart';
import 'package:arvind_party/features/room/presentation/widgets/chat_box.dart';
import 'package:arvind_party/features/room/presentation/widgets/gift_animation_overlay.dart';
import 'package:arvind_party/features/room/presentation/widgets/live_kit_video_placeholder.dart';
import 'package:arvind_party/features/room/presentation/widgets/seat_grid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LiveRoomScreen extends StatelessWidget {
  const LiveRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The controller is initialized via GetX bindings, we just find it.
    final controller = Get.find<LiveRoomController>();
    final chatInputController = TextEditingController();

    return WillPopScope(
      onWillPop: () async {
        // Ensure we gracefully leave the room and release resources.
        controller.onClose();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Obx(
          () {
            if (!controller.isLiveKitInitialized.value || !controller.isConnected.value) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Connecting to Room...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              );
            }
            return SafeArea(
              child: Stack(
                children: [
                  // Layer 1: LiveKit video placeholder (streaming handled via LiveKit tracks)
                  const LiveKitVideoPlaceholder(),

                  // Layer 2: Main Room UI (Header, Seats, Chat, Controls)
                  Column(
                    children: [
                      _buildHeader(controller),
                      const SizedBox(height: 16),
                      // The dynamic grid of seats
                      const SeatGrid(),
                      const Spacer(),
                      // The scrolling list of chat messages
                      const ChatBox(),
                    ],
                  ),
                  
                  // Layer 3: Bottom Action Bar for user input
                  _buildBottomBar(context, controller, chatInputController),

                  // Layer 4: Gift Animation Overlay
                  const GiftAnimationOverlay(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(LiveRoomController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Room ID: ${controller.roomId}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                'Owner: ${controller.roomOwnerId}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          )),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, LiveRoomController controller, TextEditingController chatInputController) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
          left: 16,
          right: 16,
          top: 8,
        ),
        color: Colors.black.withOpacity(0.3),
        child: Row(
          children: [
            // Chat Input Field
            Expanded(
              child: TextField(
                controller: chatInputController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Say something...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  border: InputBorder.none,
                ),
                onSubmitted: (text) {
                  controller.sendChatMessage(text);
                  chatInputController.clear();
                },
              ),
            ),
            // Send Chat Button
            IconButton(
              icon: const Icon(Icons.send, color: Color(0xFFFF8906)),
              onPressed: () {
                controller.sendChatMessage(chatInputController.text);
                chatInputController.clear();
              },
            ),
            // Gift Button
            IconButton(
              icon: const Icon(Icons.card_giftcard, color: Colors.pinkAccent),
              onPressed: () {
                Get.bottomSheet(
                  Container(
                    height: 340,
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Send a Gift', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                              onPressed: () => Get.back(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Obx(() {
                            if (controller.availableGifts.isEmpty) {
                              return const Center(
                                child: Text('No gifts available', style: TextStyle(color: Colors.white38)),
                              );
                            }
                            return GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 0.8,
                              ),
                              itemCount: controller.availableGifts.length,
                              itemBuilder: (ctx, index) {
                                final gift = controller.availableGifts[index];
                                return InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    controller.sendGiftToRoom(gift);
                                    Get.back();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.06),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.network(
                                          gift['iconUrl'] ?? '',
                                          width: 40,
                                          height: 40,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.card_giftcard, color: Colors.pinkAccent, size: 28),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          gift['name']?.toString() ?? 'Gift',
                                          style: const TextStyle(color: Colors.white, fontSize: 11),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        Text(
                                          '${gift['cost']} coins',
                                          style: const TextStyle(color: Colors.amber, fontSize: 10),
                                        ),
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
                  ),
                );
              },
            ),
            // Mute/Unmute Button
            Obx(() => IconButton(
                  icon: Icon(
                    controller.isMuted.value ? Icons.mic_off : Icons.mic,
                    color: controller.isMuted.value ? Colors.red : Colors.white,
                  ),
                  onPressed: () => controller.toggleMute(),
                )),
          ],
        ),
      ),
    );
  }
}
