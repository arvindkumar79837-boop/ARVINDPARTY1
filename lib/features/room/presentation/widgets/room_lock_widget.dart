import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/api_service.dart';

class RoomLockWidget extends StatefulWidget {
  final String roomId;
  final bool isOwner;
  final bool isLocked;

  const RoomLockWidget({
    super.key,
    required this.roomId,
    this.isOwner = false,
    this.isLocked = false,
  });

  @override
  State<RoomLockWidget> createState() => _RoomLockWidgetState();
}

class _RoomLockWidgetState extends State<RoomLockWidget> {
  bool _locked = false;
  String _expiresAt = '';

  @override
  void initState() {
    super.initState();
    _locked = widget.isLocked;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isOwner) {
      return _buildOwnerLockButton();
    }
    if (_locked) {
      return _buildLockedBadge();
    }
    return const SizedBox.shrink();
  }

  Widget _buildOwnerLockButton() {
    return GestureDetector(
      onTap: () => _showLockDialog(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _locked ? const Color(0xFF9C27B0).withValues(alpha: 0.2) : Colors.white10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _locked ? const Color(0xFF9C27B0) : Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_locked ? Icons.lock : Icons.lock_open, size: 16, color: _locked ? const Color(0xFF9C27B0) : Colors.white54),
            const SizedBox(width: 4),
            Text(_locked ? 'Locked' : 'Lock', style: TextStyle(color: _locked ? const Color(0xFF9C27B0) : Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF9C27B0).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock, size: 14, color: Color(0xFF9C27B0)),
          SizedBox(width: 4),
          Text('Private Room', style: TextStyle(color: Color(0xFF9C27B0), fontSize: 11)),
        ],
      ),
    );
  }

  void _showLockDialog() {
    final pinCtrl = TextEditingController();
    final costCtrl = TextEditingController(text: '50');
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Row(
          children: [
            const Icon(Icons.lock, color: Color(0xFF9C27B0)),
            const SizedBox(width: 8),
            const Text('Lock Room', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Set a PIN to make this a private room.', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: pinCtrl,
              keyboardType: TextInputType.number,
              maxLength: 8,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'PIN (4-8 digits)',
                labelStyle: const TextStyle(color: Colors.white54),
                hintText: 'e.g. 1234',
                hintStyle: const TextStyle(color: Colors.white24),
                counterStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: costCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Duration (hours)',
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8906).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFFFF8906), size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Cost: 50 coins (configurable by admin)', style: TextStyle(color: Color(0xFFFF8906), fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () async {
              if (pinCtrl.text.length < 4) {
                Get.snackbar('Error', 'PIN must be at least 4 digits', backgroundColor: Colors.red.shade900, colorText: Colors.white);
                return;
              }
              try {
                final api = Get.find<ApiService>();
                final resp = await api.dio.post('/luxury/rooms/${widget.roomId}/lock', data: {
                  'pin': pinCtrl.text,
                  'durationHours': int.tryParse(costCtrl.text) ?? 6,
                });
                if (resp.data['success'] == true) {
                  setState(() => _locked = true);
                  Get.back();
                  Get.snackbar('Locked', 'Room is now private', backgroundColor: const Color(0xFF9C27B0), colorText: Colors.white);
                } else {
                  Get.snackbar('Error', resp.data['message'] ?? 'Failed', backgroundColor: Colors.red.shade900, colorText: Colors.white);
                }
              } catch (e) {
                Get.snackbar('Error', 'Failed: $e', backgroundColor: Colors.red.shade900, colorText: Colors.white);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9C27B0)),
            child: const Text('Lock', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  static void showPinEntryDialog(String roomId) {
    final pinCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Row(
          children: [
            Icon(Icons.lock, color: Color(0xFF9C27B0)),
            SizedBox(width: 8),
            Text('Enter PIN', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: TextField(
          controller: pinCtrl,
          keyboardType: TextInputType.number,
          maxLength: 8,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Room PIN',
            labelStyle: const TextStyle(color: Colors.white54),
            counterStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () async {
              if (pinCtrl.text.isEmpty) return;
              try {
                final api = Get.find<ApiService>();
                final resp = await api.dio.post('/luxury/rooms/$roomId/unlock-attempt', data: {'pin': pinCtrl.text});
                if (resp.data['success'] == true) {
                  Get.back(result: true);
                  Get.snackbar('Welcome', 'PIN verified', backgroundColor: const Color(0xFF4CAF50), colorText: Colors.white);
                } else {
                  Get.snackbar('Wrong PIN', resp.data['message'] ?? 'Try again', backgroundColor: Colors.red.shade900, colorText: Colors.white);
                }
              } catch (e) {
                Get.snackbar('Error', 'Failed: $e', backgroundColor: Colors.red.shade900, colorText: Colors.white);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9C27B0)),
            child: const Text('Join', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
