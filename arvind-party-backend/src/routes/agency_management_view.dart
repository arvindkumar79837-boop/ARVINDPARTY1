import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/agency_controller.dart';

class AgencyManagementView extends StatefulWidget {
  const AgencyManagementView({super.key});

  @override
  State<AgencyManagementView> createState() => _AgencyManagementViewState();
}

class _AgencyManagementViewState extends State<AgencyManagementView> {
  late final AgencyController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AgencyController());
  }

  void _showCreateDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF15141F),
        title: const Text('Create New Agency',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: controller.agencyNameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Agency Name',
                    labelStyle: TextStyle(color: Colors.white54))),
            const SizedBox(height: 16),
            TextField(
                controller: controller.ownerUidController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    labelText: 'Owner UID',
                    labelStyle: TextStyle(color: Colors.white54))),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white54))),
          ElevatedButton(
              onPressed: () => controller.createAgency(),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8906)),
              child:
                  const Text('CREATE', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  void _showHostsDialog(Map<String, dynamic> agency) {
    final agencyId = agency['_id'] ?? agency['id'] ?? '';
    controller.fetchAgencyHosts(agencyId);

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF15141F),
        title: Text('${agency['name']} - Hosts',
            style: const TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 500,
          height: 400,
          child: Obx(() {
            if (controller.isLoadingHosts.value) {
              return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF8906)));
            }
            if (controller.agencyHosts.isEmpty) {
              return const Center(
                  child: Text('No hosts found in this agency.',
                      style: TextStyle(color: Colors.white54)));
            }
            return ListView.builder(
              itemCount: controller.agencyHosts.length,
              itemBuilder: (context, index) {
                final host = controller.agencyHosts[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                        host['avatar'] ?? 'https://via.placeholder.com/150'),
                  ),
                  title: Text(host['name'] ?? 'Unknown User',
                      style: const TextStyle(color: Colors.white)),
                  subtitle: Text('UID: ${host['uid'] ?? 'N/A'}',
                      style: const TextStyle(color: Colors.white54)),
                  trailing: Text('🪙 ${host['coins'] ?? 0}',
                      style: const TextStyle(
                          color: Colors.yellow, fontWeight: FontWeight.bold)),
                );
              },
            );
          }),
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child:
                  const Text('Close', style: TextStyle(color: Colors.white54))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Agency Control Panel',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                ElevatedButton.icon(
                  onPressed: _showCreateDialog,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Create Agency',
                      style: TextStyle(color: Colors.white)),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                )
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFFFF8906)));
                }
                if (controller.agencies.isEmpty) {
                  return const Center(
                      child: Text('No agencies found.',
                          style: TextStyle(color: Colors.white54)));
                }
                return SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12)),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(Colors.black38),
                      columns: const [
                        DataColumn(
                            label: Text('Agency Name',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF8906)))),
                        DataColumn(
                            label: Text('Owner UID',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF8906)))),
                        DataColumn(
                            label: Text('Total Earnings',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF8906)))),
                        DataColumn(
                            label: Text('Action',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF8906)))),
                      ],
                      rows: controller.agencies.map((agency) {
                        return DataRow(cells: [
                          DataCell(Text(agency['name'] ?? '',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))),
                          DataCell(Text(agency['ownerUid'] ?? '',
                              style: const TextStyle(color: Colors.white70))),
                          DataCell(Text('\$${agency['earnings'] ?? 0}',
                              style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold))),
                          DataCell(ElevatedButton(
                              onPressed: () => _showHostsDialog(agency),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2B2118)),
                              child: const Text('VIEW HOSTS',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12)))),
                        ]);
                      }).toList(),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
