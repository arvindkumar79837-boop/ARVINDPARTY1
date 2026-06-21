// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/room/presentation/views/room_lock_screen.dart
// ARVIND PARTY - ROOM LOCK SCREEN (Stable Version)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RoomLockScreen extends StatelessWidget {
  const RoomLockScreen({super.key});
  
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
          'Room Lock & Privacy',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildRoomTypeSection(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.withValues(alpha: 0.15), Colors.purple.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
      ),
      child: const Text(
        'Room security controls will be available after backend integration.',
        style: TextStyle(color: Colors.white70, fontSize: 14),
      ),
    );
  }

  Widget _buildRoomTypeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: const Text(
        'Room lock feature requires backend support.\nCurrently set to: Public',
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}