// ═══════════════════════════════════════════════════════════════════════════
// MODULE: Admin Agency Management Dashboard
// ARVIND PARTY - Web Admin Panel
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class AgencyManagementView extends GetView<AgencyManagementController> {
  const AgencyManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agency Management'),
        backgroundColor: Colors.purple[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadAgencies,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.agencies.isEmpty) {
                return const Center(child: Text('No agencies found', style: TextStyle(color: Colors.grey)));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: controller.agencies.length,
                itemBuilder: (context, index) => _buildAgencyCard(controller.agencies[index]),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.purple[50],
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('Total Agencies', controller.totalAgencies.toString(), Colors.purple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('Active', controller.activeAgencies.toString(), Colors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard('Total Hosts', controller.totalHosts.toString(), Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAgencyCard(Map<String, dynamic> agency) {
    final agencyId = agency['_id'] ?? '';
    final name = agency['name'] ?? 'Unnamed Agency';
    final description = agency['description'] ?? '';
    final ownerName = agency['ownerName'] ?? 'Unknown';
    final totalHosts = agency['totalHosts'] ?? 0;
    final earnings = agency['earnings'] ?? 0;
    final isApproved = agency['isApproved'] ?? false;
    final status = agency['status'] ?? 'pending';
    final createdAt = agency['createdAt'] != null 
        ? DateTime.parse(agency['createdAt']).toString().split(' ')[0]
        : 'N/A';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple[100],
          child: const Icon(Icons.business, color: Colors.purple),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Owner: $ownerName | Hosts: $totalHosts | Earnings: $earnings'),
            Text('Status: ${isApproved ? "Active" : "Pending"} | Created: $createdAt'),
            if (description.isNotEmpty)
              Text(description, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isApproved)
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                onPressed: () => controller.approveAgency(agencyId),
                tooltip: 'Approve Agency',
              ),
            if (isApproved)
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                onPressed: () => controller.revokeAgency(agencyId),
                tooltip: 'Revoke Agency',
              ),
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.blue),
              onPressed: () => controller.viewAgencyDetails(agencyId),
              tooltip: 'View Details',
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Agency ID: $agencyId', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => controller.viewHosts(agencyId),
                        icon: const Icon(Icons.people),
                        label: const Text('View Hosts'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => controller.viewEarnings(agencyId),
                        icon: const Icon(Icons.trending_up),
                        label: const Text('View Earnings'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AgencyManagementController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final RxList<Map<String, dynamic>> agencies = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt totalAgencies = 0.obs;
  final RxInt activeAgencies = 0.obs;
  final RxInt totalHosts = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadAgencies();
  }

  Future<void> loadAgencies() async {
    isLoading.value = true;
    try {
      final response = await _api.get('/api/admin/agencies');
      if (response['success'] == true) {
        final data = response['data'] as List;
        agencies.assignAll(data.map((e) => Map<String, dynamic>.from(e)).toList());
        totalAgencies.value = data.length;
        activeAgencies.value = agencies.where((a) => a['isApproved'] == true).length;
        totalHosts.value = agencies.fold<int>(0, (sum, a) => sum + ((a['totalHosts'] ?? 0) as int));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load agencies: $e', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveAgency(String agencyId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Approve Agency'),
        content: const Text('Are you sure you want to approve this agency?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await _api.post('/api/admin/agencies/approve/$agencyId', {});
      if (response['success'] == true) {
        Get.snackbar('Success', 'Agency approved', backgroundColor: Colors.green, colorText: Colors.black);
        loadAgencies();
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to approve agency', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Operation failed: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> revokeAgency(String agencyId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Revoke Agency'),
        content: const Text('Are you sure you want to revoke this agency? This action can be reversed.'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await _api.post('/api/admin/agencies/revoke/$agencyId', {});
      if (response['success'] == true) {
        Get.snackbar('Success', 'Agency revoked', backgroundColor: Colors.green, colorText: Colors.black);
        loadAgencies();
      } else {
        Get.snackbar('Error', response['message'] ?? 'Failed to revoke agency', backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Operation failed: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void viewAgencyDetails(String agencyId) {
    Get.toNamed('/admin/agency-details', arguments: {'agencyId': agencyId});
  }

  void viewHosts(String agencyId) {
    Get.toNamed('/admin/agency-hosts', arguments: {'agencyId': agencyId});
  }

  void viewEarnings(String agencyId) {
    Get.toNamed('/admin/agency-earnings', arguments: {'agencyId': agencyId});
  }
}