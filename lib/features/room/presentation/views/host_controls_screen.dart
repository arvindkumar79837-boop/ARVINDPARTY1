// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/room/presentation/views/host_controls_screen.dart
// ARVIND PARTY - HOST CONTROLS SCREEN (Stable Version)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/room_models.dart';
import '../controllers/room_controller.dart';

class HostControlsScreen extends StatelessWidget {
  final String roomId;
  const HostControlsScreen({super.key, required this.roomId});

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
          'Host Controls',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildRoomInfoCard(controller),
            const SizedBox(height: 24),
            _buildMemberManagementSection(controller),
            const SizedBox(height: 24),
            _buildSeatManagementSection(controller),
            const SizedBox(height: 24),
            _buildRoomSettingsSection(controller),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomInfoCard(RoomController controller) {
    return Obx(() {
      final room = controller.currentRoom.value;
      if (room == null) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1E88E5).withValues(alpha: 0.15),
              const Color(0xFF1E88E5).withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF1E88E5).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star_outlined, color: Colors.amber, size: 24),
                const SizedBox(width: 10),
                Text(
                  room.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.people_outline, size: 16, color: Colors.white.withValues(alpha: 0.6)),
                const SizedBox(width: 6),
                Text(
                  '${room.currentMembers} members',
                  style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
                ),
                const SizedBox(width: 16),
                Icon(Icons.chat_bubble_outline, size: 16, color: Colors.white.withValues(alpha: 0.6)),
                const SizedBox(width: 6),
                Text(
                  '${room.seatCount} seats',
                  style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMemberManagementSection(RoomController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Member Management',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.members.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('No members yet', style: TextStyle(color: Colors.white54)),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.members.length,
            itemBuilder: (context, index) {
              final member = controller.members[index];
              final isHost = member.role == MemberRole.host;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: member.avatar != null ? NetworkImage(member.avatar!) : null,
                      backgroundColor: Colors.grey[800],
                      child: member.avatar == null
                          ? const Icon(Icons.person, color: Colors.white54, size: 20)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.userName,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getRoleLabel(member.role),
                            style: TextStyle(fontSize: 11, color: _getRoleColor(member.role)),
                          ),
                        ],
                      ),
                    ),
                    if (!isHost)
                      IconButton(
                        onPressed: () => _showMemberOptionsDialog(controller, member),
                        icon: Icon(Icons.more_vert, color: Colors.white.withValues(alpha: 0.6), size: 20),
                      ),
                  ],
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildSeatManagementSection(RoomController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seat Management',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildActionButton(icon: Icons.info_outline, label: 'Mute All', color: Colors.orange, onTap: () {})),
            const SizedBox(width: 12),
            Expanded(child: _buildActionButton(icon: Icons.info_outline, label: 'Unmute All', color: Colors.green, onTap: () {})),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildActionButton(icon: Icons.info_outline, label: 'Lock All Seats', color: Colors.red, onTap: () {})),
            const SizedBox(width: 12),
            Expanded(child: _buildActionButton(icon: Icons.info_outline, label: 'Unlock All Seats', color: Colors.blue, onTap: () {})),
          ],
        ),
      ],
    );
  }

  Widget _buildRoomSettingsSection(RoomController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Room Settings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        _buildSettingsTile(
          icon: Icons.lock_outlined,
          title: 'Room Lock & Password',
          subtitle: 'Set password or make room private',
          onTap: () => Get.toNamed('/room-lock'),
        ),
        _buildSettingsTile(
          icon: Icons.image_outlined,
          title: 'Room Background',
          subtitle: 'Change room background image',
          onTap: () => Get.toNamed('/room-background'),
        ),
        _buildSettingsTile(
          icon: Icons.analytics_outlined,
          title: 'Room Analytics',
          subtitle: 'View live room statistics',
          onTap: () => Get.toNamed('/room-analytics'),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF64B5F6).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF64B5F6), size: 18),
        ),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white.withValues(alpha: 0.3)),
        onTap: onTap,
      ),
    );
  }

  String _getRoleLabel(MemberRole role) {
    switch (role) {
      case MemberRole.host: return 'Host';
      case MemberRole.coHost: return 'Co-Host';
      case MemberRole.admin: return 'Admin';
      case MemberRole.moderator: return 'Moderator';
      case MemberRole.speaker: return 'Speaker';
      case MemberRole.listener: return 'Listener';
      default: return 'Member';
    }
  }

  Color _getRoleColor(MemberRole role) {
    switch (role) {
      case MemberRole.host: return Colors.amber;
      case MemberRole.coHost: return Colors.purple;
      case MemberRole.admin: return Colors.red;
      case MemberRole.moderator: return Colors.orange;
      case MemberRole.speaker: return Colors.blue;
      case MemberRole.listener: return Colors.green;
      default: return Colors.grey;
    }
  }

  void _showMemberOptionsDialog(RoomController controller, RoomMemberModel member) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF2A2A3E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Text(
              member.userName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            _buildOptionTile(
              icon: Icons.mic_off_outlined,
              label: 'Mute User',
              color: Colors.orange,
              onTap: () {
                Get.back();
                Get.snackbar('Info', 'Mute not available in this build');
              },
            ),
            _buildOptionTile(
              icon: Icons.delete_outline,
              label: 'Kick User',
              color: Colors.red,
              onTap: () {
                Get.back();
                _showKickConfirmDialog(controller, member);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 20),
      title: Text(label, style: TextStyle(color: color, fontSize: 14)),
      onTap: onTap,
    );
  }

  void _showKickConfirmDialog(RoomController controller, RoomMemberModel member) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text('Kick User?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to kick ${member.userName} from the room?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.kickMember(member.userId);
              Get.snackbar(
                'Success',
                '${member.userName} has been kicked',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green.withValues(alpha: 0.8),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Kick', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}