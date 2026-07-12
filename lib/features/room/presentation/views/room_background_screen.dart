// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/room/presentation/views/room_background_screen.dart
// ARVIND PARTY - ROOM BACKGROUND PICKER VIEW
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/room_controller.dart';

class RoomBackgroundScreen extends StatelessWidget {
  const RoomBackgroundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RoomController>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Room Background',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildPreviewCard(controller),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: _backgroundOptions.length,
                itemBuilder: (context, index) {
                  final bg = _backgroundOptions[index];
                  return _buildBackgroundOption(controller, bg);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(RoomController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withValues(alpha: 0.15),
            Colors.purple.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.image_outlined,
                color: Colors.blue,
                size: 24,
              ),
              SizedBox(width: 10),
              Text(
                'Current Background',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withValues(alpha: 0.3),
                  Colors.purple.withValues(alpha: 0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: const Center(
              child: Text(
                'Default Gradient',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundOption(RoomController controller, Map<String, dynamic> bg) {
    final isSelected = controller.selectedBackgroundName.value == bg['name'];

    return GestureDetector(
      onTap: () => _selectBackground(controller, bg),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.blue
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: bg['colors'],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Text(
                    bg['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectBackground(RoomController controller, Map<String, dynamic> bg) {
    Get.snackbar(
      'Background Updated',
      'Room background changed to ${bg['name']}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withValues(alpha: 0.8),
      colorText: Colors.white,
    );

    Get.snackbar('Info', 'Room settings update not implemented');
  }

  static final List<Map<String, dynamic>> _backgroundOptions = [
    {
      'name': 'Ocean Blue',
      'colors': [const Color(0xFF0077B6), const Color(0xFF00B4D8)],
    },
    {
      'name': 'Sunset',
      'colors': [const Color(0xFFFF6B6B), const Color(0xFFFFA07A)],
    },
    {
      'name': 'Purple Haze',
      'colors': [const Color(0xFF9D4EDD), const Color(0xFFC77DFF)],
    },
    {
      'name': 'Forest',
      'colors': [const Color(0xFF2D6A4F), const Color(0xFF52B788)],
    },
    {
      'name': 'Midnight',
      'colors': [const Color(0xFF0D1B2A), const Color(0xFF1B263B)],
    },
    {
      'name': 'Golden Hour',
      'colors': [const Color(0xFFFFB703), const Color(0xFFFB8500)],
    },
    {
      'name': 'Cherry Blossom',
      'colors': [const Color(0xFFFFB3C6), const Color(0xFFFF8FAB)],
    },
    {
      'name': 'Aurora',
      'colors': [const Color(0xFF00FF87), const Color(0xFF60EFFE)],
    },
    {
      'name': 'Galaxy',
      'colors': [const Color(0xFF240046), const Color(0xFF5A189A)],
    },
    {
      'name': 'Minimal',
      'colors': [const Color(0xFF2B2D42), const Color(0xFF8D99AE)],
    },
  ];
}