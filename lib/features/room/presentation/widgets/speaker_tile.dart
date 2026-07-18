// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/room/presentation/widgets/speaker_tile.dart
// ARVIND PARTY - SPEAKER TILE WIDGET (Avatar, Role Badge, Speaking Waves)
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../../models/room_models.dart';
import '../controllers/room_controller.dart';

class SpeakerTile extends StatelessWidget {
  final RoomMemberModel member;
  final bool isSpeaking;
  final bool isMuted;
  final VoidCallback? onTap;

  const SpeakerTile({
    super.key,
    required this.member,
    this.isSpeaking = false,
    this.isMuted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RoomController>();

    return GestureDetector(
      onTap: onTap ?? () => _showSpeakerOptions(ctrl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Avatar + Speaking Waves + Role Badge ───────────────────────
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Speaking glow ring
              Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSpeaking && !isMuted
                        ? const Color(0xFFFF8906)
                        : Colors.transparent,
                    width: 2.5,
                  ),
                  boxShadow: isSpeaking && !isMuted
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFF8906).withValues(alpha: 0.35),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF2A2838),
                  backgroundImage: member.avatar != null &&
                          member.avatar!.isNotEmpty
                      ? NetworkImage(member.avatar!)
                      : null,
                  child: member.avatar == null || member.avatar!.isEmpty
                      ? const Icon(Icons.person, color: Colors.white38, size: 26)
                      : null,
                ),
              ),

              // Animated Speaking Waves
              if (isSpeaking && !isMuted)
                Positioned.fill(
                  child: _SpeakingWaves(),
                ),

              // Role Badge (top-right)
              Positioned(
                top: -4,
                right: -4,
                child: _RoleBadge(role: member.role),
              ),

              // Muted Badge (bottom-right)
              if (isMuted)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mic_off,
                      color: Colors.white,
                      size: 11,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Name ───────────────────────────────────────────────────────
          SizedBox(
            width: 72,
            child: Text(
              member.userName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 2),

          // ── Role Label ─────────────────────────────────────────────────
          Text(
            _roleLabel(member.role),
            style: TextStyle(
              color: _roleColor(member.role),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showSpeakerOptions(RoomController ctrl) {
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

            // Avatar + Name
            CircleAvatar(
              radius: 32,
              backgroundColor: const Color(0xFF2A2838),
              backgroundImage: member.avatar != null && member.avatar!.isNotEmpty
                  ? NetworkImage(member.avatar!)
                  : null,
              child: member.avatar == null || member.avatar!.isEmpty
                  ? const Icon(Icons.person, color: Colors.white38, size: 28)
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: _roleColor(member.role).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _roleLabel(member.role),
                style: TextStyle(
                  color: _roleColor(member.role),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Options
            if (canManage) ...[
              if (member.role == MemberRole.speaker)
                _OptionTile(
                  icon: Icons.arrow_downward,
                  iconColor: Colors.amber,
                  label: 'Move to Listener',
                  onTap: () {
                    Get.back();
                    ctrl.kickMember(member.userId);
                  },
                ),
              _OptionTile(
                icon: isMuted ? Icons.mic : Icons.mic_off,
                iconColor: const Color(0xFFFF8906),
                label: isMuted ? 'Unmute Mic' : 'Mute Mic',
                onTap: () {
                  Get.back();
                  ctrl.toggleMute();
                },
              ),
              if (member.role != MemberRole.host &&
                  member.role != MemberRole.coHost)
                _OptionTile(
                  icon: Icons.star_outline,
                  iconColor: Colors.cyanAccent,
                  label: 'Promote to Co-Host',
                  onTap: () {
                    Get.back();
                    // Promote action
                  },
                ),
              _OptionTile(
                icon: Icons.person_remove,
                iconColor: Colors.redAccent,
                label: 'Remove from Stage',
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
            ],
          ],
        ),
      ),
    );
  }

  String _roleLabel(MemberRole role) {
    switch (role) {
      case MemberRole.host:
        return 'HOST';
      case MemberRole.coHost:
        return 'CO-HOST';
      case MemberRole.speaker:
        return 'SPEAKER';
      case MemberRole.moderator:
        return 'MOD';
      default:
        return 'STAGE';
    }
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
// ANIMATED SPEAKING WAVES
// ─────────────────────────────────────────────────────────────────────────────

class _SpeakingWaves extends StatefulWidget {
  @override
  State<_SpeakingWaves> createState() => _SpeakingWavesState();
}

class _SpeakingWavesState extends State<_SpeakingWaves>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(64, 64),
          painter: _SpeakingWavesPainter(
            progress: _controller.value,
          ),
        );
      },
    );
  }
}

class _SpeakingWavesPainter extends CustomPainter {
  final double progress;

  _SpeakingWavesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var i = 0; i < 3; i++) {
      final phase = (progress + i * 0.33) % 1.0;
      final radius = 32.0 + phase * 14.0;
      final opacity = (1.0 - phase).clamp(0.0, 1.0);

      paint.color = const Color(0xFFFF8906).withValues(alpha: opacity * 0.5);

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_SpeakingWavesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ROLE BADGE
// ─────────────────────────────────────────────────────────────────────────────

class _RoleBadge extends StatelessWidget {
  final MemberRole role;

  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    if (role == MemberRole.listener || role == MemberRole.visitor) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: _badgeColor,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: _badgeColor.withValues(alpha: 0.4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Text(
        _badgeLabel,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 7,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color get _badgeColor {
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

  String get _badgeLabel {
    switch (role) {
      case MemberRole.host:
        return 'HOST';
      case MemberRole.coHost:
        return 'CO-HOST';
      case MemberRole.moderator:
        return 'MOD';
      case MemberRole.speaker:
        return 'SPEAKER';
      default:
        return '';
    }
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
