// ═══════════════════════════════════════════════════════════════════════════
// VIEW: SecurityView — Security logs and IP blocking
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/role_permission_service.dart';

class SecurityView extends StatefulWidget {
  const SecurityView({super.key});

  @override
  State<SecurityView> createState() => _SecurityViewState();
}

class _SecurityViewState extends State<SecurityView> {
  final _permService = Get.find<RolePermissionService>();
  final _apiService = Get.find<ApiService>();

  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = true;

  final _blockIpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  @override
  void dispose() {
    _blockIpController.dispose();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/security/logins');
      if (response['success'] == true) {
        _logs = List<Map<String, dynamic>>.from(response['data'] ?? []);
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _blockIp() async {
    final ip = _blockIpController.text.trim();
    if (ip.isEmpty) return;

    try {
      await _apiService.post('/security/block-ip', {'ip': ip});
      Get.snackbar('Success', 'IP blocked: $ip', backgroundColor: Colors.green);
      _blockIpController.clear();
    } catch (_) {
      Get.snackbar('Error', 'Failed to block IP', backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canBlock = _permService.hasPermission('security.block_ip');

    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (canBlock) ...[
                    const Text('Block IP Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _blockIpController, decoration: const InputDecoration(labelText: 'IP Address', border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(onPressed: _blockIp, icon: const Icon(Icons.block), label: const Text('Block')),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                  const Text('Login History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _logs.isEmpty
                      ? const Text('No login logs found')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _logs.length,
                          itemBuilder: (ctx, i) {
                            final log = _logs[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(Icons.security, color: Colors.blue),
                                title: Text(log['ip'] ?? 'Unknown IP'),
                                subtitle: Text('${log['userAgent'] ?? ''} | ${log['timestamp'] ?? ''}'),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}