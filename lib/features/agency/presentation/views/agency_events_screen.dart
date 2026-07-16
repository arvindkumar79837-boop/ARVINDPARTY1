import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/agency_controller.dart';

class AgencyEventsScreen extends StatelessWidget {
  const AgencyEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text('Agency Events', style: TextStyle(color: Colors.white, fontSize: 20)),
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    Tab(text: 'Upcoming'),
                    Tab(text: 'Past'),
                    Tab(text: 'All'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildEventsList(isUpcoming: true),
                    _buildEventsList(isPast: true),
                    _buildEventsList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF8906),
        onPressed: () => _showCreateEventDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEventsList({bool isUpcoming = false, bool isPast = false}) {
    final events = [
      {
        'title': 'Agency Meet & Greet',
        'date': isPast ? 'Jun 15, 2026' : 'Jul 25, 2026',
        'time': '6:00 PM',
        'attendees': 18,
        'status': isPast ? 'completed' : 'upcoming',
        'type': 'meeting',
        'color': Colors.blue,
      },
      {
        'title': 'Live Streaming Contest',
        'date': isPast ? 'Jun 10, 2026' : 'Aug 01, 2026',
        'time': '8:00 PM',
        'attendees': 32,
        'status': isPast ? 'completed' : 'upcoming',
        'type': 'contest',
        'color': Colors.orange,
      },
      {
        'title': 'Training Workshop',
        'date': isPast ? 'Jun 05, 2026' : 'Aug 10, 2026',
        'time': '4:00 PM',
        'attendees': 12,
        'status': isPast ? 'completed' : 'upcoming',
        'type': 'training',
        'color': Colors.green,
      },
      {
        'title': 'Performance Awards Night',
        'date': isPast ? 'May 30, 2026' : 'Aug 20, 2026',
        'time': '7:30 PM',
        'attendees': 24,
        'status': isPast ? 'completed' : 'upcoming',
        'type': 'ceremony',
        'color': Colors.purple,
      },
    ];

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text('No events found', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final color = event['color'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.12),
                color.withValues(alpha: 0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_getEventIcon(event['type'] as String), color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['title'] as String,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: Colors.white.withValues(alpha: 0.5)),
                        const SizedBox(width: 4),
                        Text(
                          '${event['date']} at ${event['time']}',
                          style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.people_outline, size: 12, color: Colors.white.withValues(alpha: 0.5)),
                        const SizedBox(width: 4),
                        Text(
                          '${event['attendees']} attendees',
                          style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (event['status'] as String == 'completed')
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  (event['status'] as String == 'completed') ? 'Done' : 'RSVP',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: (event['status'] as String == 'completed') ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'meeting':
        return Icons.groups_outlined;
      case 'contest':
        return Icons.emoji_events_outlined;
      case 'training':
        return Icons.school_outlined;
      case 'ceremony':
        return Icons.celebration_outlined;
      default:
        return Icons.event_outlined;
    }
  }

  void _showCreateEventDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text('Create Event', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Event Title',
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
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                Get.back();
                Get.snackbar(
                  'Event Created',
                  '"${titleController.text.trim()}" has been scheduled.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green.withValues(alpha: 0.8),
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
