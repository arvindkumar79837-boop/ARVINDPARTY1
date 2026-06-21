// ═══════════════════════════════════════════════════════════════════════════
// VIEW: RoomManagementView — Room moderation and live room management
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/role_permission_service.dart';

class RoomManagementView extends StatefulWidget {
  const RoomManagementView({super.key});

  @override
  State<RoomManagementView> createState() => _RoomManagementViewState();
}

class _RoomManagementViewState extends State<RoomManagementView> {
  final _permService = Get.find<RolePermissionService>();
  final _apiService = Get.find<ApiService>();

  List<Map<String, dynamic>> _rooms = [];
  bool _isLoading = true;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() => _isLoading = true);
    try {
      final queryParams = <String, String>{};
      if (_filter == 'live') queryParams['status'] = 'live';
      if (_filter == 'banned') queryParams['isBanned'] = 'true';

      final response = await _apiService.get('/rooms', queryParams: queryParams);
      if (response['success'] == true) {
        _rooms = List<Map<String, dynamic>>.from(response['data'] ?? []);
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _toggleRoomStatus(String roomId, bool currentStatus) async {
    try {
      await _apiService.post('/rooms/${currentStatus ? 'unban' : 'ban'}/$roomId', {});
      Get.snackbar('Success', currentStatus ? 'Room unbanned' : 'Room banned', backgroundColor: Colors.green);
      _loadRooms();
    } catch (_) {
      Get.snackbar('Error', 'Operation failed', backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canModerate = _permService.hasPermission('rooms.moderate');

    return Scaffold(
      appBar: AppBar(title: const Text('Room Management')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Filter: ', style: TextStyle(fontWeight: FontWeight.bold)),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'all', label: Text('All')),
                    ButtonSegment(value: 'live', label: Text('Live')),
                    ButtonSegment(value: 'banned', label: Text('Banned')),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (v) { setState(() => _filter = v.first); _loadRooms(); },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _rooms.isEmpty
                    ? const Center(child: Text('No rooms found'))
                    : ListView.builder(
                        itemCount: _rooms.length,
                        itemBuilder: (ctx, i) {
                          final room = _rooms[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: Icon(Icons.meeting_room, color: room['isLive'] == true ? Colors.red : Colors.grey),
                              title: Text(room['title'] ?? 'Untitled Room'),
                              subtitle: Text('Host: ${room['hostName'] ?? 'Unknown'} | Viewers: ${room['viewerCount'] ?? 0}'),
                              trailing: canModerate
                                  ? IconButton(
                                      icon: Icon(room['isBanned'] == true ? Icons.lock_open : Icons.lock,
                                          color: room['isBanned'] == true ? Colors.green : Colors.red),
                                      onPressed: () => _toggleRoomStatus(room['_id'], room['isBanned'] == true),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}