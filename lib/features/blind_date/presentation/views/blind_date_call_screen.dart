import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/blind_date_controller.dart';
import 'blind_date_decision_screen.dart';

class BlindDateCallScreen extends StatelessWidget {
  const BlindDateCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BlindDateController>();
    return Obx(() {
      final s = ctrl.session.value;
      final other = s?['otherUser'];
      final icebreaker = s?['icebreaker'] ?? 'Say something interesting!';
      final coins = s?['coinsCharged'] ?? 0;

      if (ctrl.match.value == null) return const SizedBox();

      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A0033), Color(0xFF0D001A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Avatar
              CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFFFF6B9D).withOpacity(0.3),
                backgroundImage: other?['avatar'] != null ? NetworkImage(other!['avatar']) : null,
                child: other?['avatar'] == null ? const Icon(Icons.person, size: 60, color: Colors.white) : null,
              ),
              const SizedBox(height: 16),
              // Name + status
              Text(
                other?['name'] ?? 'Blind Date',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: Color(0xFF4CAF50), size: 8),
                    SizedBox(width: 6),
                    Text('Connected', style: TextStyle(color: Color(0xFF4CAF50), fontSize: 12)),
                  ],
                ),
              ),
              if (coins > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Coins: $coins',
                    style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11),
                  ),
                ),
              ],
              const Spacer(),
              // Icebreaker prompt
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.chat_bubble_outline, color: Color(0xFFFF6B9D), size: 24),
                    const SizedBox(height: 8),
                    Text(
                      icebreaker,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _actionButton(
                      icon: Icons.close,
                      color: Colors.red,
                      label: 'End',
                      onTap: () => _showEndDialog(ctrl),
                    ),
                    _actionButton(
                      icon: Icons.report_outlined,
                      color: Colors.orange,
                      label: 'Report',
                      onTap: () => _showReportDialog(ctrl),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      );
    });
  }

  Widget _actionButton({required IconData icon, required Color color, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }

  void _showEndDialog(BlindDateController ctrl) {
    Get.dialog(
      AlertDialog(
        title: const Text('End Call?'),
        content: const Text('Are you sure you want to end this blind date?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ctrl.endCall();
              Get.back();
              Get.back();
            },
            child: const Text('End', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BlindDateController ctrl) {
    Get.dialog(
      AlertDialog(
        title: const Text('Report User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _reportOption(ctrl, 'HARASSMENT', 'Harassment or bullying'),
            _reportOption(ctrl, 'INAPPROPRIATE', 'Inappropriate behavior'),
            _reportOption(ctrl, 'FAKE_ACCOUNT', 'Fake account'),
            _reportOption(ctrl, 'SPAM', 'Spam or scam'),
          ],
        ),
      ),
    );
  }

  Widget _reportOption(BlindDateController ctrl, String reason, String label) {
    return ListTile(
      leading: const Icon(Icons.warning_amber, color: Colors.red),
      title: Text(label),
      onTap: () {
        ctrl.reportSession(reason);
        Get.back();
      },
    );
  }
}
