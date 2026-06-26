import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/auth/controllers/role_auth_controller.dart';

class SecurityDashboardView extends StatelessWidget {
  SecurityDashboardView({super.key});

  final RoleAuthController authController = Get.find<RoleAuthController>();

  // Dummy data for UI representation
  final List<Map<String, String>> liveAttacks = [
    {'type': 'VPN_ACCESS_BLOCKED', 'ip': '103.22.11.5', 'country': 'Singapore', 'time': '2s ago'},
    {'type': 'SPAM_CHAT_MUTED', 'user': 'UID: 88321', 'ip': '192.168.1.10', 'country': 'India', 'time': '1m ago'},
    {'type': 'FAKE_RECHARGE_ATTEMPT', 'user': 'UID: 10293', 'ip': '22.11.33.44', 'country': 'USA', 'time': '5m ago'},
  ];

  final List<Map<String, String>> blockedDevices = [
    {'deviceId': 'A8S9-D7F6-G5H4-J3K2', 'reason': 'Repeated Ban Evasion', 'bannedAt': '2023-10-27 10:00'},
    {'deviceId': 'L1P0-O2I9-U8Y7-T6R5', 'reason': 'Fraudulent Activity', 'bannedAt': '2023-10-26 18:30'},
  ];

  final List<Map<String, String>> suspiciousUsers = [
    {'uid': '99812', 'reason': 'Abnormal Coin Transfer Volume', 'flaggedAt': '2023-10-27 11:00'},
    {'uid': '10500', 'reason': 'Multiple Logins from Different IPs', 'flaggedAt': '2023-10-27 10:45'},
  ];

  @override
  Widget build(BuildContext context) {
    // Extra Protection: Ensure only authorized roles can view this page.
    if (!authController.hasPermission('SECURITY_DASHBOARD')) {
      return const Scaffold(
        backgroundColor: Color(0xFF14141F),
        body: Center(
          child: Text(
            "ACCESS DENIED: You do not have permission to view the Security Dashboard.",
            style: TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF14141F),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              "Live Security & Anti-Fraud Dashboard",
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Real-time monitoring of cyber threats, blocked entities, and suspicious activities across the platform.",
              style: TextStyle(color: Color(0xA3FFFFFF), fontSize: 14),
            ),
            const SizedBox(height: 32),

            // Main Grid
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildDashboardCard(
                        title: "Live Threat Feed",
                        icon: Icons.local_fire_department,
                        iconColor: Colors.redAccent,
                        child: _buildLiveThreatsTable(),
                      ),
                      const SizedBox(height: 24),
                      _buildDashboardCard(
                        title: "Suspicious User Accounts (Auto-Flagged)",
                        icon: Icons.person_search,
                        iconColor: Colors.yellow,
                        child: _buildGenericTable(suspiciousUsers, ['UID', 'Reason', 'Flagged At']),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Right Column
                Expanded(
                  flex: 1,
                  child: _buildDashboardCard(
                    title: "Permanently Blocked Devices",
                    icon: Icons.phonelink_erase,
                    iconColor: Colors.purpleAccent,
                    child: _buildGenericTable(blockedDevices, ['Device ID', 'Reason', 'Banned At']),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({required String title, required IconData icon, required Color iconColor, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2D2D44)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: Color(0xFF2D2D44), height: 32),
          child,
        ],
      ),
    );
  }

  Widget _buildLiveThreatsTable() {
    return Column(
      children: liveAttacks.map((attack) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent[100], size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'monospace'),
                    children: [
                      TextSpan(text: "${attack['type']} ", style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      TextSpan(text: "from IP ${attack['ip']} "),
                      TextSpan(text: "(${attack['country']})", style: const TextStyle(color: Colors.white54)),
                    ],
                  ),
                ),
              ),
              Text(attack['time']!, style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGenericTable(List<Map<String, String>> data, List<String> headers) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(2),
      },
      children: [
        // Header
        TableRow(
          children: headers.map((h) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(h.toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
          )).toList(),
        ),
        // Data Rows
        ...data.map((row) {
          return TableRow(
            children: row.values.map((cell) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Text(cell, style: const TextStyle(color: Colors.white, fontSize: 13)),
            )).toList(),
          );
        }),
      ],
    );
  }
}