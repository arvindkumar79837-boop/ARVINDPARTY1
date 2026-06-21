// ═══════════════════════════════════════════════════════════════════════════
// VIEW: SettingsView — System settings management
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/role_permission_service.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final _permService = Get.find<RolePermissionService>();
  final _apiService = Get.find<ApiService>();

  Map<String, dynamic> _settings = {};
  bool _isLoading = true;

  final _keyController = TextEditingController();
  final _valueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/settings');
      if (response['success'] == true) {
        _settings = Map<String, dynamic>.from(response['data'] ?? {});
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    try {
      await _apiService.put('/settings', {key: value});
      Get.snackbar('Success', 'Setting updated', backgroundColor: Colors.green);
      _loadSettings();
    } catch (_) {
      Get.snackbar('Error', 'Update failed', backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = _permService.hasPermission('settings.edit');

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Global Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ..._settings.entries.map((entry) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(entry.key),
                    subtitle: Text('${entry.value}'),
                    trailing: canEdit
                        ? ElevatedButton(onPressed: () => _updateSetting(entry.key, entry.value), child: const Text('Update'))
                        : null,
                  ),
                )),
                const SizedBox(height: 24),
                if (canEdit) ...[
                  const Text('Add Custom Setting', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(controller: _keyController, decoration: const InputDecoration(labelText: 'Key', border: OutlineInputBorder())),
                  const SizedBox(height: 8),
                  TextField(controller: _valueController, decoration: const InputDecoration(labelText: 'Value', border: OutlineInputBorder())),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(onPressed: () {
                    if (_keyController.text.isNotEmpty) {
                      _updateSetting(_keyController.text, _valueController.text);
                      _keyController.clear();
                      _valueController.clear();
                    }
                  }, icon: const Icon(Icons.add), label: const Text('Add Setting')),
                ],
              ],
            ),
    );
  }
}