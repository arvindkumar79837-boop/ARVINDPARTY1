// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/room/presentation/views/moderator_controls_screen.dart
// ARVIND PARTY - MODERATOR CONTROLS PANEL (Stable Version)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ModeratorControlsScreen extends StatelessWidget {
  const ModeratorControlsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          'Moderator Controls',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Moderator controls will be available after backend integration.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}