import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/blind_date_controller.dart';

class BlindDateDecisionScreen extends StatelessWidget {
  const BlindDateDecisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BlindDateController>();
    return Obx(() {
      final s = ctrl.session.value;
      final matched = s?['status'] == 'MATCHED';
      final myDecision = s?['myDecision'];

      if (matched) {
        return _matchedView(ctrl, s);
      }

      if (myDecision != null && myDecision != 'PENDING') {
        return _decisionRecordedView(myDecision);
      }

      return _decisionView(ctrl);
    });
  }

  Widget _decisionView(BlindDateController ctrl) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF1A0033), Color(0xFF0D001A)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, size: 60, color: Color(0xFFFF6B9D)),
            const SizedBox(height: 16),
            Text(
              ctrl.session.value?['icebreaker'] ?? 'Say something interesting!',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ).paddingSymmetric(horizontal: 32),
            const SizedBox(height: 12),
            Text(
              'How did this conversation go?',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
            ),
            const Spacer(),
            _decisionButton(
              label: 'Interested',
              icon: Icons.favorite,
              color: const Color(0xFFFF6B9D),
              onTap: () => ctrl.makeDecision('INTERESTED'),
            ),
            const SizedBox(height: 16),
            _decisionButton(
              label: 'Pass',
              icon: Icons.close,
              color: Colors.grey.shade700,
              onTap: () => ctrl.makeDecision('PASS'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _showReportDialog(ctrl),
              child: Text('Report', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _decisionButton({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(30)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _matchedView(BlindDateController ctrl, Map<String, dynamic>? s) {
    final other = s?['otherUser'];
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFFFF6B9D), Color(0xFFFF1493)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('It\'s a Match!', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white.withOpacity(0.3),
              backgroundImage: other?['avatar'] != null ? NetworkImage(other!['avatar']) : null,
              child: other?['avatar'] == null ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
            ),
            const SizedBox(height: 16),
            Text(
              'You and ${other?['name'] ?? 'someone'} liked each other!',
              style: const TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'You can now continue chatting!',
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => ctrl.endCall(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                  child: const Text('Back to Explore', style: TextStyle(color: Color(0xFFFF6B9D), fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _decisionRecordedView(String decision) {
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1A0033), Color(0xFF0D001A)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              decision == 'INTERESTED' ? Icons.favorite : Icons.close,
              size: 60,
              color: decision == 'INTERESTED' ? const Color(0xFFFF6B9D) : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              decision == 'INTERESTED' ? 'Waiting for the other person...' : 'Pass recorded',
              style: const TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              decision == 'INTERESTED' ? 'If they\'re interested too, it\'s a match!' : 'No worries, better luck next time!',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
