// ═══════════════════════════════════════════════════════════════════════════
// VIEW: EventManagementView — Event CRUD
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/role_permission_service.dart';

class EventManagementView extends StatefulWidget {
  const EventManagementView({super.key});

  @override
  State<EventManagementView> createState() => _EventManagementViewState();
}

class _EventManagementViewState extends State<EventManagementView> {
  final _permService = Get.find<RolePermissionService>();
  final _apiService = Get.find<ApiService>();

  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _typeController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _typeController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/events');
      if (response['success'] == true) {
        _events = List<Map<String, dynamic>>.from(response['data'] ?? []);
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _addEvent() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      Get.snackbar('Error', 'Event title required', backgroundColor: Colors.red);
      return;
    }

    try {
      await _apiService.post('/events', {
        'title': title,
        'description': _descriptionController.text.trim(),
        'type': _typeController.text.trim(),
        'startDate': _startDateController.text.trim(),
        'endDate': _endDateController.text.trim(),
      });
      Get.snackbar('Success', 'Event created', backgroundColor: Colors.green);
      _clearControllers();
      _loadEvents();
    } catch (_) {
      Get.snackbar('Error', 'Creation failed', backgroundColor: Colors.red);
    }
  }

  void _clearControllers() {
    _titleController.clear();
    _descriptionController.clear();
    _typeController.clear();
    _startDateController.clear();
    _endDateController.clear();
  }

  Future<void> _deleteEvent(String eventId) async {
    try {
      await _apiService.delete('/events/$eventId');
      Get.snackbar('Success', 'Event deleted', backgroundColor: Colors.green);
      _loadEvents();
    } catch (_) {
      Get.snackbar('Error', 'Delete failed', backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = _permService.hasPermission('events.create');

    return Scaffold(
      appBar: AppBar(title: const Text('Event Management')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (canEdit) ...[
                    const Text('Create Event', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Event Title', border: OutlineInputBorder())),
                    const SizedBox(height: 8),
                    TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()), maxLines: 2),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _typeController, decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: _startDateController, decoration: const InputDecoration(labelText: 'Start Date', border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _endDateController, decoration: const InputDecoration(labelText: 'End Date', border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(onPressed: _addEvent, icon: const Icon(Icons.add), label: const Text('Create')),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                  const Text('All Events', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _events.isEmpty
                      ? const Text('No events found')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _events.length,
                          itemBuilder: (ctx, i) {
                            final event = _events[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(Icons.event, color: Colors.blue),
                                title: Text(event['title'] ?? 'Untitled'),
                                subtitle: Text('${event['type'] ?? ''} | ${event['startDate'] ?? ''} to ${event['endDate'] ?? ''}'),
                                trailing: canEdit
                                    ? IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteEvent(event['_id']))
                                    : null,
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}