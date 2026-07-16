import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/room_controller.dart';
import '../widgets/room_banner_widget.dart';
import '../widgets/room_bottom_bar_widget.dart';
import '../widgets/room_chat_widget.dart';
import '../widgets/room_header_widget.dart';
import '../widgets/seat_grid_widget.dart';

class RoomScreen extends StatelessWidget {
  const RoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RoomController>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitDialog(ctrl);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0E17),
        body: SafeArea(
          child: Column(
            children: [
              const RoomHeaderWidget(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const RoomBannerWidget(),
                      const SizedBox(height: 8),
                      const SeatGridWidget(),
                      const SizedBox(height: 8),
                      Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                      const SizedBox(height: 4),
                      const RoomChatWidget(),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
              const RoomBottomBarWidget(),
            ],
          ),
        ),
      ),
    );
  }

  void _showExitDialog(RoomController ctrl) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF15141F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Leave Room?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to exit this party session?',
          style: TextStyle(color: Colors.white60, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Stay', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              Get.back(result: true);
              ctrl.leaveRoom();
            },
            child: const Text(
              'Leave',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ).then((result) {
      if (result != true) {
        // Dialog was dismissed without pressing Leave (e.g. tapped outside).
        // PopScope will re-intercept back attempts normally.
      }
    });
  }
}
