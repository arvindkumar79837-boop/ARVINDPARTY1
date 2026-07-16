import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/family_controller.dart';

class FamilyEventsScreen extends StatelessWidget {
  const FamilyEventsScreen({super.key});

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
        title: const Text('Family Events', style: TextStyle(color: Colors.white, fontSize: 20)),
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
                  indicatorColor: Colors.deepPurple,
                  labelColor: Colors.deepPurple,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  tabs: [
                    Tab(text: 'Upcoming'),
                    Tab(text: 'Active'),
                    Tab(text: 'Past'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildEventsList(type: 'upcoming'),
                    _buildEventsList(type: 'active'),
                    _buildEventsList(type: 'past'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6C3CE0),
        onPressed: () => _showCreateEventDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEventsList({required String type}) {
    final events = [
      {
        'title': 'Family Game Night',
        'date': type == 'past' ? 'Jun 28, 2026' : type == 'active' ? 'Jul 16, 2026' : 'Jul 25, 2026',
        'time': '8:00 PM',
        'participants': type == 'past' ? 18 : type == 'active' ? 12 : 0,
        'maxParticipants': 20,
        'type': 'game',
        'color': Colors.blue,
        'status': type,
      },
      {
        'title': 'Birthday Celebration',
        'date': type == 'past' ? 'Jun 20, 2026' : type == 'active' ? 'Jul 16, 2026' : 'Aug 05, 2026',
        'time': '7:00 PM',
        'participants': type == 'past' ? 22 : type == 'active' ? 15 : 0,
        'maxParticipants': 25,
        'type': 'celebration',
        'color': Colors.pink,
        'status': type,
      },
      {
        'title': 'Weekly Task Challenge',
        'date': type == 'past' ? 'Jun 15, 2026' : type == 'active' ? 'Jul 16, 2026' : 'Jul 20, 2026',
        'time': 'All Day',
        'participants': type == 'past' ? 20 : type == 'active' ? 18 : 0,
        'maxParticipants': 30,
        'type': 'challenge',
        'color': Colors.orange,
        'status': type,
      },
      {
        'title': 'Family Meetup',
        'date': type == 'past' ? 'Jun 10, 2026' : type == 'active' ? 'Jul 16, 2026' : 'Aug 15, 2026',
        'time': '5:00 PM',
        'participants': type == 'past' ? 15 : type == 'active' ? 0 : 0,
        'maxParticipants': 20,
        'type': 'social',
        'color': Colors.green,
        'status': type,
      },
    ];

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text('No $type events', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 16)),
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
        final participants = event['participants'] as int;
        final maxParticipants = event['maxParticipants'] as int;
        final progress = maxParticipants > 0 ? participants / maxParticipants : 0.0;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_getEventIcon(event['type'] as String), color: color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event['title'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 12, color: Colors.white.withValues(alpha: 0.5)),
                            const SizedBox(width: 4),
                            Text('${event['date']} • ${event['time']}', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (type == 'upcoming')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('RSVP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.deepPurple)),
                    ),
                  if (type == 'active')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('LIVE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.green)),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.people_outline, size: 14, color: Colors.white.withValues(alpha: 0.5)),
                  const SizedBox(width: 4),
                  Text('$participants / $maxParticipants participants', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 12),
              if (type == 'upcoming')
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Get.snackbar('Event Details', 'Viewing details for ${event['title']}',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: color.withValues(alpha: 0.8),
                              colorText: Colors.white);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: color.withValues(alpha: 0.4)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('Details', style: TextStyle(color: color)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.snackbar('RSVP Sent', 'You have RSVPed to ${event['title']}',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green.withValues(alpha: 0.8),
                              colorText: Colors.white);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Join', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              if (type == 'active')
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.snackbar('Entering Event', 'Joining ${event['title']}...',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green.withValues(alpha: 0.8),
                              colorText: Colors.white);
                        },
                        icon: const Icon(Icons.login, size: 16),
                        label: const Text('Enter Event'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'game':
        return Icons.videogame_asset_outlined;
      case 'celebration':
        return Icons.celebration_outlined;
      case 'challenge':
        return Icons.emoji_events_outlined;
      case 'social':
        return Icons.groups_outlined;
      default:
        return Icons.event_outlined;
    }
  }

  void _showCreateEventDialog(BuildContext context) {
    final titleController = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text('Create Family Event', style: TextStyle(color: Colors.white)),
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
                    borderSide: const BorderSide(color: Colors.deepPurple),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.deepPurple.withValues(alpha: 0.7), size: 18),
                    const SizedBox(width: 10),
                    Text('Select Date & Time', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14)),
                  ],
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
                  '"${titleController.text.trim()}" has been created.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.deepPurple.withValues(alpha: 0.8),
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
