import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/users_controller.dart';

class UserManagementView extends StatefulWidget {
  const UserManagementView({super.key});

  @override
  State<UserManagementView> createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView> {
  late final UsersController controller;

  @override
  void initState() {
    super.initState();
    // Put controller in memory if not already there
    controller = Get.put(UsersController());
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
            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Global User Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => controller.loadUsers(),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'Refresh',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF15141F),
                    side: const BorderSide(color: Color(0xFFFF8906)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'View, manage, and control access for all app users.',
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 24),

            // DATA TABLE
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF8906)),
                  );
                }

                if (controller.users.isEmpty) {
                  return const Center(
                    child: Text(
                      'No users found.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(Colors.black38),
                      dataRowMinHeight: 60,
                      dataRowMaxHeight: 60,
                      columns: const [
                        DataColumn(
                          label: Text(
                            'User Profile',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF8906),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Coins / Diamonds',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF8906),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Status',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF8906),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Actions',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF8906),
                            ),
                          ),
                        ),
                      ],
                      rows: controller.users.map((user) {
                        final isBlocked = user['isBlocked'] == true;
                        final id = user['_id'] ?? user['id'] ?? '';
                        final name = user['name'] ?? 'Unknown User';
                        final uid = user['uid']?.toString() ?? 'N/A';

                        return DataRow(
                          cells: [
                            // USER PROFILE
                            DataCell(
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      user['avatar'] ??
                                          'https://via.placeholder.com/150',
                                    ),
                                    radius: 18,
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'UID: $uid',
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // WALLET INFO
                            DataCell(
                              Text(
                                '🪙 ${user['coins'] ?? 0}  |  💎 ${user['diamonds'] ?? 0}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                            // STATUS
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isBlocked
                                      ? Colors.redAccent.withOpacity(0.2)
                                      : Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isBlocked ? 'Banned' : 'Active',
                                  style: TextStyle(
                                    color: isBlocked
                                        ? Colors.redAccent
                                        : Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            // ACTIONS
                            DataCell(
                              ElevatedButton(
                                onPressed: () => isBlocked
                                    ? controller.unblockUser(id)
                                    : controller.blockUser(id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isBlocked
                                      ? Colors.green
                                      : Colors.redAccent,
                                ),
                                child: Text(
                                  isBlocked ? 'UNBAN' : 'BAN',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
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
