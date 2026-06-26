import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/agency_controller.dart';

class AgencyHomeScreen extends StatelessWidget {
  const AgencyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AgencyController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agency Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.loadAgencyData();
              controller.fetchRealtimeAnalytics();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.agencyData.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final agency = controller.agencyData.value;
        if (agency == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No agency found'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showCreateAgencyDialog(context, controller),
                  child: const Text('Create Agency'),
                ),
              ],
            ),
          );
        }

        final analytics = controller.realtimeAnalytics.value;
        final analyticsData = analytics != null ? analytics['data'] as Map<String, dynamic>? : null;

        return RefreshIndicator(
          onRefresh: () async {
            await controller.loadAgencyData();
            await controller.fetchRealtimeAnalytics();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildAgencyHeader(agency),
              const SizedBox(height: 20),
              _buildAnalyticsGrid(analyticsData),
              const SizedBox(height: 20),
              _buildQuickActions(context, controller),
              const SizedBox(height: 20),
              _buildLiveHostsSection(analyticsData, controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAgencyHeader(Map<String, dynamic> agency) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: agency['logo'] != null && agency['logo'].isNotEmpty
                      ? NetworkImage(agency['logo'])
                      : null,
                  child: agency['logo'] == null || agency['logo'].isEmpty
                      ? const Icon(Icons.business, size: 30)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agency['name'] ?? 'Agency',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${agency['totalHosts'] ?? 0} Hosts',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsGrid(Map<String, dynamic>? data) {
    if (data == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Analytics loading...'),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Live Now', '${data['liveNow'] ?? 0}', Colors.green, Icons.live_tv),
        _buildStatCard('Done Today', '${data['doneToday'] ?? 0}', Colors.blue, Icons.check_circle),
        _buildStatCard('Not Started', '${data['notStarted'] ?? 0}', Colors.orange, Icons.pending),
        _buildStatCard('Total Hosts', '${data['totalHosts'] ?? 0}', Colors.purple, Icons.people),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AgencyController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.person_add,
                label: 'Host Requests',
                color: Colors.blue,
                onTap: () => Get.to(() => const HostRequestsScreen()),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionButton(
                icon: Icons.people,
                label: 'Agents',
                color: Colors.purple,
                onTap: () => Get.to(() => const AgentsScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.attach_money,
                label: 'Salary',
                color: Colors.green,
                onTap: () => Get.to(() => const SalaryScreen()),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionButton(
                icon: Icons.bar_chart,
                label: 'Reports',
                color: Colors.orange,
                onTap: () => Get.to(() => const ReportsScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLiveHostsSection(Map<String, dynamic>? analytics, AgencyController controller) {
    final liveHosts = analytics != null ? analytics['liveHosts'] as List<dynamic>? ?? [] : [];
    final doneHosts = analytics != null ? analytics['doneHosts'] as List<dynamic>? ?? [] : [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (liveHosts.isNotEmpty) ...[
              const Text('Currently Live:', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              ...liveHosts.map((host) => ListTile(
                leading: CircleAvatar(child: Text('${host['userId']?[0] ?? '?'}')),
                title: Text('Host ${host['userId']?.substring(0, 8) ?? 'Unknown'}'),
                subtitle: Text('${host['minutes'] ?? 0} min today'),
                trailing: const Icon(Icons.live_tv, color: Colors.green, size: 20),
              )),
              const SizedBox(height: 8),
            ],
            if (doneHosts.isNotEmpty) ...[
              const Text('Completed Today:', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text('${doneHosts.length} hosts completed 2+ hours'),
            ],
            if (liveHosts.isEmpty && doneHosts.isEmpty)
              const Text('No activity yet today', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _showCreateAgencyDialog(BuildContext context, AgencyController controller) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Agency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Agency Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                controller.createAgency(
                  name: nameController.text.trim(),
                  description: descController.text.trim(),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class HostRequestsScreen extends StatelessWidget {
  const HostRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AgencyController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Host Requests')),
      body: Obx(() {
        if (controller.hostRequests.isEmpty) {
          return const Center(child: Text('No pending requests'));
        }

        return ListView.builder(
          itemCount: controller.hostRequests.length,
          itemBuilder: (context, index) {
            final request = controller.hostRequests[index];
            final userId = request['userId'] as Map<String, dynamic>?;
            final userName = userId?['name'] ?? 'Unknown';
            final userUid = userId?['uid'] ?? '';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(child: Text(userName[0])),
                title: Text(userName),
                subtitle: Text('UID: $userUid'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () {
                        controller.approveHostRequest(request['_id']);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        controller.rejectHostRequest(request['_id']);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class AgentsScreen extends StatelessWidget {
  const AgentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AgencyController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Agents')),
      body: Obx(() {
        if (controller.agents.isEmpty) {
          return const Center(child: Text('No agents yet'));
        }

        return ListView.builder(
          itemCount: controller.agents.length,
          itemBuilder: (context, index) {
            final agent = controller.agents[index];
            final recruiter = agent['recruiterId'] as Map<String, dynamic>?;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: agent['avatar'] != null && agent['avatar'].isNotEmpty
                      ? NetworkImage(agent['avatar'])
                      : null,
                  child: agent['avatar'] == null || agent['avatar'].isEmpty
                      ? Text(agent['name']?[0] ?? '?')
                      : null,
                ),
                title: Text(agent['name'] ?? 'Agent'),
                subtitle: Text('Hosts recruited: ${agent['totalHostsRecruited'] ?? 0}'),
                trailing: Text('${agent['commissionRate'] ?? 5}%'),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAgentDialog(context, controller),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddAgentDialog(BuildContext context, AgencyController controller) {
    final uidController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Agent'),
        content: TextField(
          controller: uidController,
          decoration: const InputDecoration(
            labelText: 'User UID',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (uidController.text.trim().isNotEmpty) {
                controller.addAgent(uidController.text.trim());
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class SalaryScreen extends StatelessWidget {
  const SalaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AgencyController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Salary History')),
      body: Obx(() {
        if (controller.salaryHistory.isEmpty) {
          return const Center(child: Text('No salary records'));
        }

        return ListView.builder(
          itemCount: controller.salaryHistory.length,
          itemBuilder: (context, index) {
            final record = controller.salaryHistory[index];
            final user = record['userId'] as Map<String, dynamic>?;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: user?['avatar'] != null && user!['avatar'].isNotEmpty
                      ? NetworkImage(user['avatar'])
                      : null,
                  child: (user?['avatar'] == null || user?['avatar'].isEmpty)
                      ? Text(user?['name']?[0] ?? '?')
                      : null,
                ),
                title: Text(user?['name'] ?? 'Unknown'),
                subtitle: Text('Month: ${record['month']}/${record['year']}'),
                trailing: Text(
                  '${record['totalPaid'] ?? 0}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AgencyController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Analytics')),
      body: Obx(() {
        final report = controller.monthlyReport.value;

        if (report == null) {
          return const Center(child: Text('No report data available'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildReportCard('Total Hosts', '${report['totalHosts'] ?? 0}', Colors.blue),
            _buildReportCard('Active Hosts', '${report['totalActiveHosts'] ?? 0}', Colors.green),
            _buildReportCard('Attendance Days', '${report['totalAttendanceDays'] ?? 0}', Colors.orange),
            _buildReportCard('Gifts Received', '${report['totalGiftsReceived'] ?? 0}', Colors.purple),
            _buildReportCard('Total Earnings', '${report['totalEarnings'] ?? 0}', Colors.teal),
            _buildReportCard('Salary Paid', '${report['totalSalaryPaid'] ?? 0}', Colors.red),
            _buildReportCard('Commission Earned', '${report['agencyCommissionEarned'] ?? 0}', Colors.amber),
          ],
        );
      }),
    );
  }

  Widget _buildReportCard(String title, String value, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Text(value[0])),
        title: Text(title),
        trailing: Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ),
    );
  }
}