// ═══════════════════════════════════════════════════════════════════════════
// VIEW: MobileSecurityScreen — Mobile App Security Status
// Shows device lock, session info, and security alerts.
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_session_manager.dart';
import '../../models/auth_model.dart';

class MobileSecurityScreen extends StatefulWidget {
  const MobileSecurityScreen({super.key});

  @override
  State<MobileSecurityScreen> createState() => _MobileSecurityScreenState();
}

class _MobileSecurityScreenState extends State<MobileSecurityScreen> {
  final _api = Get.find<ApiService>();
  final _auth = Get.find<AuthSessionManager>();
  var isLoading = true.obs;
  var securityInfo = <String, dynamic>{}.obs;
  var sessions = <Map<String, dynamic>>[].obs;

  @override
  void initState() {
    super.initState();
    _loadSecurityInfo();
  }

  Future<void> _loadSecurityInfo() async {
    isLoading.value = true;
    try {
      final res = await _api.get('/security/dashboard');
      if (res['success'] == true) {
        securityInfo.value = Map<String, dynamic>.from(res['data'] ?? {});
      }
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> _loadSessions() async {
    try {
      final res = await _api.get('/auth/sessions');
      if (res['success'] == true) {
        sessions.value = List<Map<String, dynamic>>.from(res['data'] ?? []);
      }
    } catch (_) {}
  }

  Future<void> _revokeAllSessions() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revoke all sessions?'),
        content: const Text('You will be logged out from all devices.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Revoke')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _api.post('/auth/revoke-all-sessions', {});
      Get.snackbar('Done', 'All sessions revoked.', backgroundColor: Colors.green);
      await _loadSecurityInfo();
    } catch (_) {
      Get.snackbar('Error', 'Failed to revoke sessions.', backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionHeader('Account Status'),
            Card(
              child: ListTile(
                leading: const Icon(Icons.shield, color: Colors.green),
                title: const Text('Account Standing'),
                subtitle: Text(securityInfo['flaggedUsers'] != null && securityInfo['flaggedUsers'] > 0
                    ? 'Flagged (${securityInfo['flaggedUsers']})'
                    : 'Good'),
              ),
            ),
            const SizedBox(height: 16),
            _sectionHeader('Security Summary'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.report, color: Colors.red),
                    title: const Text('Open Fraud Alerts'),
                    trailing: Text('${securityInfo['openFraudAlerts'] ?? 0}'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.warning, color: Colors.orange),
                    title: const Text('Critical Alerts'),
                    trailing: Text('${securityInfo['criticalFraudAlerts'] ?? 0}'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phonelink_erase, color: Colors.deepPurple),
                    title: const Text('Banned Devices'),
                    trailing: Text('${securityInfo['bannedDevices'] ?? 0}'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock, color: Colors.blue),
                    title: const Text('Blocked IPs'),
                    trailing: Text('${securityInfo['blockedIps'] ?? 0}'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _sectionHeader('Active Sessions'),
            Card(
              child: ListTile(
                leading: const Icon(Icons.devices, color: Colors.teal),
                title: const Text('Revoke all other sessions'),
                subtitle: const Text('Forces re-login on all devices'),
                trailing: const Icon(Icons.logout),
                onTap: _revokeAllSessions,
              ),
            ),
            const SizedBox(height: 16),
            _sectionHeader('Device Info'),
            Card(
              child: ListTile(
                leading: const Icon(Icons.fingerprint, color: Colors.indigo),
                title: const Text('Device fingerprint'),
                subtitle: FutureBuilder<String>(
                  future: _auth.getDeviceFingerprint(),
                  builder: (ctx, snap) => Text(snap.data ?? ''),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadSecurityInfo,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        );
      }),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }
}