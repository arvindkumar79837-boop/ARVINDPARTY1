import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/agency_controller.dart';

class AgencyMembersScreen extends StatelessWidget {
  const AgencyMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AgencyController>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('Agency Members', style: TextStyle(color: Colors.white, fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined, color: Colors.white),
            onPressed: () => _showInviteDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: DefaultTabController(
                length: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const TabBar(
                    indicatorColor: Colors.orange,
                    labelColor: Colors.orange,
                    unselectedLabelColor: Colors.white54,
                    labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    tabs: [
                      Tab(text: 'Hosts'),
                      Tab(text: 'Agents'),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildMembersList(controller, role: 'host'),
                  _buildMembersList(controller, role: 'agent'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersList(AgencyController controller, {required String role}) {
    final members = [
      {
        'name': 'Rahul Verma',
        'uid': 'RL_28491',
        'role': 'host',
        'coins': 45200,
        'hours': '120h',
        'attendance': 92,
        'avatar': 'R',
        'color': Colors.blue,
        'status': 'active',
      },
      {
        'name': 'Priya Sharma',
        'uid': 'PS_39182',
        'role': 'host',
        'coins': 38700,
        'hours': '98h',
        'attendance': 88,
        'avatar': 'P',
        'color': Colors.pink,
        'status': 'active',
      },
      {
        'name': 'Amit Kumar',
        'uid': 'AK_15734',
        'role': 'agent',
        'coins': 22400,
        'hours': '65h',
        'attendance': 95,
        'avatar': 'A',
        'color': Colors.green,
        'status': 'active',
      },
      {
        'name': 'Sneha Patel',
        'uid': 'SP_42671',
        'role': 'host',
        'coins': 31500,
        'hours': '85h',
        'attendance': 78,
        'avatar': 'S',
        'color': Colors.orange,
        'status': 'active',
      },
      {
        'name': 'Vikram Singh',
        'uid': 'VS_61029',
        'role': 'host',
        'coins': 18900,
        'hours': '52h',
        'attendance': 71,
        'avatar': 'V',
        'color': Colors.teal,
        'status': 'inactive',
      },
    ];

    final filtered = members.where((m) => m['role'] == role).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text('No ${role}s yet', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final member = filtered[index];
        final color = member['color'] as Color;
        final isActive = member['status'] == 'active';
        final attendance = member['attendance'] as int;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: color.withValues(alpha: 0.2),
                    child: Text(member['avatar'] as String, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member['name'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                        const SizedBox(height: 2),
                        Text('UID: ${member['uid']}', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isActive ? 'Active' : 'Inactive',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isActive ? Colors.green : Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildMemberStat(Icons.monetization_on_outlined, '${member['coins']}', Colors.amber),
                  const SizedBox(width: 16),
                  _buildMemberStat(Icons.access_time, member['hours'] as String, Colors.blue),
                  const SizedBox(width: 16),
                  _buildMemberStat(Icons.calendar_today, '$attendance%', attendance >= 80 ? Colors.green : Colors.red),
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.white.withValues(alpha: 0.5), size: 20),
                    onSelected: (value) => _handleMenuAction(value, member),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'stats', child: Text('View Stats')),
                      const PopupMenuItem(value: 'message', child: Text('Send Message')),
                      const PopupMenuItem(value: 'remove', child: Text('Remove', style: TextStyle(color: Colors.red))),
                    ],
                    color: const Color(0xFF2A2A3E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.show_chart, size: 12, color: Colors.white.withValues(alpha: 0.4)),
                  const SizedBox(width: 4),
                  Text('Attendance', style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.4))),
                  const Spacer(),
                  Text('$attendance%', style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.4))),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: attendance / 100,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    attendance >= 80 ? Colors.green : attendance >= 60 ? Colors.orange : Colors.red,
                  ),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMemberStat(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }

  void _handleMenuAction(String action, Map<String, dynamic> member) {
    switch (action) {
      case 'stats':
        Get.snackbar('Stats', 'Viewing stats for ${member['name']}', snackPosition: SnackPosition.BOTTOM);
        break;
      case 'message':
        Get.snackbar('Message', 'Opening chat with ${member['name']}', snackPosition: SnackPosition.BOTTOM);
        break;
      case 'remove':
        Get.dialog(
          AlertDialog(
            backgroundColor: const Color(0xFF2A2A3E),
            title: const Text('Remove Member', style: TextStyle(color: Colors.white)),
            content: Text('Remove ${member['name']} from the agency?', style: const TextStyle(color: Colors.white70)),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.snackbar('Removed', '${member['name']} has been removed', snackPosition: SnackPosition.BOTTOM);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Remove', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
        break;
    }
  }

  void _showInviteDialog(BuildContext context) {
    final uidController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text('Invite Member', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: uidController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'User UID',
            hintText: 'Enter the user\'s UID',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.orange),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              if (uidController.text.trim().isNotEmpty) {
                Get.back();
                Get.snackbar('Invitation Sent', 'Request sent to ${uidController.text.trim()}',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.withValues(alpha: 0.8),
                    colorText: Colors.white);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Send Invite', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
