import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/rooms_controller.dart';

class RoomManagementView extends StatefulWidget {
  const RoomManagementView({super.key});

  @override
  State<RoomManagementView> createState() => _RoomManagementViewState();
}

class _RoomManagementViewState extends State<RoomManagementView> {
  late final RoomsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(RoomsController());
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
                const Text(
                  'Global Room Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => controller.loadRooms(),
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
            const SizedBox(height: 24),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF8906)),
                  );
                }
                if (controller.rooms.isEmpty) {
                  return const Center(
                    child: Text(
                      'No active rooms found.',
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
                      columns: const [
                        DataColumn(
                          label: Text(
                            'Room ID',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF8906),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Room Name',
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
                            'Action',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF8906),
                            ),
                          ),
                        ),
                      ],
                      rows: controller.rooms.map((room) {
                        final isActive = room['isActive'] != false;
                        final id = room['_id'] ?? room['id'] ?? '';
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                id.toString().length > 6
                                    ? '${id.toString().substring(0, 6)}...'
                                    : id,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                            DataCell(
                              Text(
                                room['title'] ?? 'Lounge Room',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Colors.green.withOpacity(0.2)
                                      : Colors.redAccent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isActive ? 'LIVE' : 'CLOSED',
                                  style: TextStyle(
                                    color: isActive
                                        ? Colors.green
                                        : Colors.redAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              ElevatedButton(
                                onPressed: isActive
                                    ? () => controller.closeRoom(id)
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isActive
                                      ? Colors.redAccent
                                      : Colors.grey,
                                ),
                                child: const Text(
                                  'FORCE CLOSE',
                                  style: TextStyle(color: Colors.white),
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
