import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MobileSecurityScreen extends StatelessWidget {
  const MobileSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('Security Center', style: TextStyle(color: Colors.white, fontSize: 20)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSecurityScoreCard(),
              const SizedBox(height: 24),
              _buildDeviceManagementSection(),
              const SizedBox(height: 24),
              _buildSecuritySettingsSection(),
              const SizedBox(height: 24),
              _buildLoginHistorySection(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityScoreCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(alpha: 0.15),
            Colors.teal.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: 0.85,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
              const Column(
                children: [
                  Text('85', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('/ 100', style: TextStyle(fontSize: 12, color: Colors.white54)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Security Score: Good', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 4),
          Text(
            'Enable 2FA and bind a device to reach 100%',
            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceManagementSection() {
    final devices = [
      {'name': 'iPhone 15 Pro', 'lastActive': 'Just now', 'icon': Icons.phone_iphone, 'color': Colors.blue, 'current': true},
      {'name': 'Samsung Galaxy S24', 'lastActive': '2 days ago', 'icon': Icons.phone_android, 'color': Colors.green, 'current': false},
      {'name': 'iPad Air', 'lastActive': '5 days ago', 'icon': Icons.tablet_mac, 'color': Colors.purple, 'current': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('My Devices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            TextButton.icon(
              onPressed: () {
                Get.snackbar('Add Device', 'Scan QR code or enter code to bind a new device',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.teal.withValues(alpha: 0.8),
                    colorText: Colors.white);
              },
              icon: const Icon(Icons.add, size: 16, color: Colors.teal),
              label: const Text('Add Device', style: TextStyle(fontSize: 12, color: Colors.teal)),
            ),
          ],
        ),
        ...devices.map((d) {
          final color = d['color'] as Color;
          final isCurrent = d['current'] as bool;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isCurrent ? color.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCurrent ? color.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(d['icon'] as IconData, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(d['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                          if (isCurrent) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('This Device', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.green)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('Last active: ${d['lastActive']}', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
                    ],
                  ),
                ),
                if (!isCurrent)
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red.withValues(alpha: 0.7), size: 20),
                    onPressed: () => _showRemoveDeviceDialog(d['name'] as String),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSecuritySettingsSection() {
    final settings = [
      {'title': 'Two-Factor Authentication', 'subtitle': 'Extra layer of security', 'icon': Icons.security, 'color': Colors.green, 'enabled': true},
      {'title': 'Device Binding', 'subtitle': 'Lock account to this device', 'icon': Icons.phone_locked, 'color': Colors.blue, 'enabled': true},
      {'title': 'Login Notifications', 'subtitle': 'Alert on new device login', 'icon': Icons.notifications_active_outlined, 'color': Colors.orange, 'enabled': false},
      {'title': 'Auto-Lock', 'subtitle': 'Lock app after 5 min inactive', 'icon': Icons.lock_outline, 'color': Colors.purple, 'enabled': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Security Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: settings.map((s) {
              final color = s['color'] as Color;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(s['icon'] as IconData, color: color, size: 20),
                ),
                title: Text(s['title'] as String, style: const TextStyle(fontSize: 14, color: Colors.white)),
                subtitle: Text(s['subtitle'] as String, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
                trailing: Switch(
                  value: s['enabled'] as bool,
                  onChanged: (val) {
                    s['enabled'] = val;
                    Get.snackbar(
                      'Setting Updated',
                      '${s['title']} ${val ? 'enabled' : 'disabled'}',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: color.withValues(alpha: 0.8),
                      colorText: Colors.white,
                    );
                  },
                  activeColor: color,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginHistorySection() {
    final logins = [
      {'device': 'iPhone 15 Pro', 'location': 'Mumbai, India', 'time': 'Just now', 'status': 'current', 'color': Colors.green},
      {'device': 'Samsung Galaxy S24', 'location': 'Delhi, India', 'time': 'Jul 14, 8:30 PM', 'status': 'success', 'color': Colors.blue},
      {'device': 'Chrome Browser', 'location': 'Bangalore, India', 'time': 'Jul 12, 2:15 PM', 'status': 'success', 'color': Colors.blue},
      {'device': 'Unknown Device', 'location': 'Kolkata, India', 'time': 'Jul 10, 11:45 PM', 'status': 'blocked', 'color': Colors.red},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Login Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        ...logins.map((l) {
          final color = l['color'] as Color;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l['device'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                      Text(
                        '${l['location']} • ${l['time']}',
                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    l['status'] == 'current' ? 'Now' : l['status'] == 'blocked' ? 'Blocked' : 'OK',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _showRemoveDeviceDialog(String deviceName) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text('Remove Device?', style: TextStyle(color: Colors.red)),
        content: Text(
          'Remove "$deviceName" from your trusted devices? You will need to verify on this device next time.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar('Device Removed', '$deviceName has been removed',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green.withValues(alpha: 0.8),
                  colorText: Colors.white);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
