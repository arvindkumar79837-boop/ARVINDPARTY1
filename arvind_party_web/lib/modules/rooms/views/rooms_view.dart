import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/rooms_controller.dart';
import '../../../shared/widgets/sidebar_widget.dart';

class RoomsView extends StatelessWidget {
  const RoomsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(RoomsController());
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      body: Row(
        children: [
          const SidebarWidget(selected: 2),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Room Management',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: ctrl.loadRooms,
                        icon: const Icon(Icons.refresh, color: Colors.white54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Obx(() {
                      if (ctrl.isLoading.value) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFF8906),
                          ),
                        );
                      }
                      if (ctrl.rooms.isEmpty) {
                        return const Center(
                          child: Text(
                            'No active rooms',
                            style: TextStyle(color: Colors.white54),
                          ),
                        );
                      }
                      return _RoomsTable(ctrl: ctrl);
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomsTable extends StatelessWidget {
  final RoomsController ctrl;

  const _RoomsTable({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateColor.resolveWith(
          (states) => const Color(0xFF1E1E1E),
        ),
        dataRowColor: WidgetStateColor.resolveWith(
          (states) => const Color(0xFF1A1A2E),
        ),
        columns: const [
          DataColumn(
            label: Text(
              'Room ID',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Title',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Owner',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Members',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Status',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Actions',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        rows: ctrl.rooms.map((room) {
          return DataRow(
            cells: [
              DataCell(
                Text(
                  room['roomId'] ?? '',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              DataCell(
                Text(
                  room['title'] ?? 'N/A',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              DataCell(
                Text(
                  room['ownerName'] ?? 'Unknown',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              DataCell(
                Text(
                  '${room['activeUsers'] ?? 0}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              DataCell(
                Chip(
                  label: Text(
                    room['status'] ?? 'inactive',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  backgroundColor: room['status'] == 'live'
                      ? Colors.green
                      : Colors.grey,
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.remove_red_eye,
                        color: Colors.blue,
                        size: 18,
                      ),
                      onPressed: () {
                        Get.snackbar(
                          'Room',
                          'Viewing room ${room['roomId']}',
                          backgroundColor: Colors.black87,
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.red,
                        size: 18,
                      ),
                      onPressed: () {
                        Get.snackbar(
                          'Room',
                          'Closed room ${room['roomId']}',
                          backgroundColor: Colors.black87,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
