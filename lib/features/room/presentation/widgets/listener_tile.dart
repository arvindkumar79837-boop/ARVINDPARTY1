// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/room/presentation/widgets/listener_tile.dart
// ARVIND PARTY - LISTENER TILE WIDGET (Avatar, Mic Indicator, Mute State)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../../models/room_models.dart';
import '../controllers/room_controller.dart';

class ListenerTile extends StatelessWidget {
  final RoomMemberModel member;
  final VoidCallback? onTap;

  const ListenerTile({
    super.key,
    required this.member,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RoomController>();

    return GestureDetector(
      onTap: onTap ?? () => _showListenerOptions(ctrl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Avatar with Mic Indicator ──────────────────────────────────
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: member.isOnline
                        ? const Color(0xFF2A2838)
                        : Colors.white.withValues(alpha: 0.05),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFF2A2838),
                  backgroundImage: member.avatar != null &&
                          member.avatar!.isNotEmpty
                      ? NetworkImage(member.avatar!)
                      : null,
                  child: member.avatar == null || member.avatar!.isEmpty
                      ? const Icon(Icons.person, color: Colors.white38, size: 20)
                      : null,
                ),
              ),

              // Animated Mic Indicator
              Positioned(
                bottom: -2,
                right: -2,
                child: _MicIndicator(isOnline: member.isOnline),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // ── Name ───────────────────────────────────────────────────────
          SizedBox(
            width: 60,
            child: Text(
              member.userName,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _showListenerOptions(RoomController ctrl) {
    final isCurrentUser = member.userId == ctrl.currentUserId;
    final canManage = ctrl.canManageMembers;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: Color(0xFF15141F),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Avatar
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFF2A2838),
              backgroundImage: member.avatar != null && member.avatar!.isNotEmpty
                  ? NetworkImage(member.avatar!)
                  : null,
              child: member.avatar == null || member.avatar!.isEmpty
                  ? const Icon(Icons.person, color: Colors.white38)
                  : null,
            ),
            const SizedBox(height: 10),

            Text(
              member.userName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              member.role.name.toUpperCase(),
              style: TextStyle(
                color: _roleColor(member.role),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Options
            if (!isCurrentUser && canManage) ...[
              _OptionTile(
                icon: Icons.mic,
                iconColor: const Color(0xFFFF8906),
                label: 'Invite to Speak',
                onTap: () {
                  Get.back();
                  ctrl.takeSeat(0);
                },
              ),
              _OptionTile(
                icon: Icons.person_remove,
                iconColor: Colors.redAccent,
                label: 'Remove from Room',
                onTap: () {
                  Get.back();
                  ctrl.kickMember(member.userId);
                },
              ),
            ],
            if (!isCurrentUser) ...[
              _OptionTile(
                icon: Icons.person_outline,
                iconColor: Colors.white54,
                label: 'View Profile',
                onTap: () {
                  Get.back();
                  Get.toNamed(AppRoutes.userProfile, arguments: {'userId': member.userId});
                },
              ),
              _OptionTile(
                icon: Icons.chat_bubble_outline,
                iconColor: Colors.cyanAccent,
                label: 'Send Message',
                onTap: () {
                  Get.back();
                  // Navigate to chat with user
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _roleColor(MemberRole role) {
    switch (role) {
      case MemberRole.host:
        return const Color(0xFFFF8906);
      case MemberRole.coHost:
        return Colors.cyanAccent;
      case MemberRole.moderator:
        return Colors.greenAccent;
      case MemberRole.speaker:
        return Colors.amber;
      default:
        return Colors.white38;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANIMATED MIC INDICATOR
// ─────────────────────────────────────────────────────────────────────────────

class _MicIndicator extends StatefulWidget {
  final bool isOnline;

  const _MicIndicator({required this.isOnline});

  @override
  State<_MicIndicator> createState() => _MicIndicatorState();
}

class _MicIndicatorState extends State<_MicIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isOnline) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_MicIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOnline && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isOnline && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: widget.isOnline ? const Color(0xFF2A2838) : const Color(0xFF1A1926),
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.isOnline ? Colors.greenAccent : Colors.white24,
                width: 1.5,
              ),
            ),
            child: Icon(
              widget.isOnline ? Icons.mic : Icons.mic_off,
              color: widget.isOnline ? Colors.greenAccent : Colors.white24,
              size: 10,
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OPTION TILE (reusable bottom-sheet item)
// ─────────────────────────────────────────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}
