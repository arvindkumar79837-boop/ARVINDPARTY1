// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/admin/presentation/views/broadcast_screen.dart
// ARVIND PARTY - SYSTEM CORE BROADCAST / ANNOUNCEMENTS
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';

class BroadcastScreen extends StatelessWidget {
  const BroadcastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();

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
          'System Broadcast',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildBroadcastForm(controller),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: Colors.orange),
                    ),
                  );
                }
                if (controller.broadcasts.isEmpty) {
                  return Center(
                    child: Text(
                      'No broadcasts yet',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => controller.loadBroadcasts(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: controller.broadcasts.length,
                    itemBuilder: (ctx, index) {
                      final broadcast = controller.broadcasts[index];
                      return _buildBroadcastCard(ctx, broadcast);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBroadcastForm(AdminController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.15),
            Colors.deepOrange.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'New Announcement',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (value) => controller.broadcastTitle.value = value,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Title',
              labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              errorText: _getTitleError(controller.broadcastTitle.value),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (value) => controller.broadcastBody.value = value,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Message',
              labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              errorText: _getBodyError(controller.broadcastBody.value),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() => Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Global', style: TextStyle(color: Colors.white)),
                  value: 'global',
                  groupValue: controller.broadcastType.value,
                  onChanged: (value) {
                    if (value != null) controller.broadcastType.value = value;
                  },
                  activeColor: Colors.orange,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Targeted', style: TextStyle(color: Colors.white)),
                  value: 'targeted',
                  groupValue: controller.broadcastType.value,
                  onChanged: (value) {
                    if (value != null) controller.broadcastType.value = value;
                  },
                  activeColor: Colors.purple,
                ),
              ),
            ],
          )),
          if (controller.broadcastType.value == 'targeted') ...[
            const SizedBox(height: 8),
            TextField(
              onChanged: (value) => controller.broadcastTarget.value = value,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Target Audience',
                labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                errorText: _getTargetError(controller.broadcastTarget.value),
              ),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.sendBroadcast(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 12),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text(
              'Send Broadcast',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBroadcastCard(BuildContext context, Map<String, dynamic> broadcast) {
    final type = broadcast['type'] as String;
    final sentAt = broadcast['sentAt'] as DateTime;
    final isRecent = DateTime.now().difference(sentAt).inHours < 24;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRecent ? Colors.orange.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: type == 'global'
                        ? [Colors.orange, Colors.deepOrange]
                        : [Colors.purple, Colors.deepPurple],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  type == 'global' ? Icons.campaign_outlined : Icons.group_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      broadcast['title'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sent by ${broadcast['sentBy']} • ${_formatTime(sentAt)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (type == 'global' ? Colors.orange : Colors.purple).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  type.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    color: type == 'global' ? Colors.orange : Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (broadcast['body'] != null) ...[
            const SizedBox(height: 8),
            Text(
              broadcast['body'],
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
          if (broadcast['target'] != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.people_outline, size: 12, color: Colors.purple),
                const SizedBox(width: 4),
                Text(
                  'Target: ${broadcast['target']}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.purple.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inHours < 1) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

  String? _getTitleError(String value) {
    if (value.isEmpty) return null;
    if (value.length < 3) return 'Title too short';
    if (value.length > 100) return 'Title too long';
    return null;
  }

  String? _getBodyError(String value) {
    if (value.isEmpty) return null;
    if (value.length < 5) return 'Message too short';
    if (value.length > 500) return 'Message too long';
    return null;
  }

  String? _getTargetError(String value) {
    if (value.isEmpty) return 'Target required';
    return null;
  }
}