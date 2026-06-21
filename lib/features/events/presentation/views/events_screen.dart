// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/events/presentation/views/events_screen.dart
// ARVIND PARTY - EVENTS SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/events_controller.dart';

class EventsScreen extends GetView<EventsController> {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateEventSheet(context),
        backgroundColor: const Color(0xFFFF8906),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Create Event', style: TextStyle(color: Colors.white)),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.events.isEmpty) {
          return const Center(
            child: Text('No upcoming events', style: TextStyle(color: Colors.grey)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.events.length,
          itemBuilder: (context, index) {
            final event = controller.events[index];
            final title = event['title']?.toString() ?? 'Untitled event';
            final status = event['status']?.toString() ?? 'upcoming';
            final type = event['type']?.toString() ?? 'special';
            final startDate = _formatDate(event['startDate']?.toString());
            final participants = event['participantsCount']?.toString() ?? '0';
            return Card(
              color: const Color(0xFF1A1A2E),
              child: ListTile(
                leading: const Icon(Icons.event, color: Color(0xFFFF8906)),
                title: Text(title, style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                  '${_labelize(type)} • $startDate • ${_labelize(status)}',
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: Text(
                  '$participants joined',
                  style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Future<void> _showCreateEventSheet(BuildContext context) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final coverImageController = TextEditingController();
    final maxParticipantsController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final type = 'party'.obs;
    final startDate = DateTime.now().add(const Duration(days: 1)).obs;
    final endDate = DateTime.now().add(const Duration(days: 2)).obs;

    await Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF121212),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Create Event',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: titleController,
                    label: 'Title',
                    hint: 'Summer Party Showdown',
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Title is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    controller: descriptionController,
                    label: 'Description',
                    hint: 'Describe the event',
                    maxLines: 4,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Description is required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Obx(() => DropdownButtonFormField<String>(
                        initialValue: type.value,
                        dropdownColor: const Color(0xFF1A1A2E),
                        decoration: _inputDecoration('Event Type'),
                        style: const TextStyle(color: Colors.white),
                        items: const [
                          DropdownMenuItem(value: 'party', child: Text('Party')),
                          DropdownMenuItem(value: 'blind_date', child: Text('Blind Date')),
                          DropdownMenuItem(value: 'lucky_draw', child: Text('Lucky Draw')),
                          DropdownMenuItem(value: 'pk_battle', child: Text('PK Battle')),
                          DropdownMenuItem(value: 'mission', child: Text('Mission')),
                          DropdownMenuItem(value: 'special', child: Text('Special')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            type.value = value;
                          }
                        },
                      )),
                  const SizedBox(height: 12),
                  _buildField(
                    controller: coverImageController,
                    label: 'Cover Image URL',
                    hint: 'https://example.com/event-cover.jpg',
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    controller: maxParticipantsController,
                    label: 'Max Participants',
                    hint: '0 for unlimited',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 16),
                  Obx(() => _dateTile(
                        context: context,
                        label: 'Start Date',
                        value: startDate.value,
                        onSelect: (value) => startDate.value = value,
                      )),
                  const SizedBox(height: 12),
                  Obx(() => _dateTile(
                        context: context,
                        label: 'End Date',
                        value: endDate.value,
                        firstDate: startDate.value,
                        onSelect: (value) => endDate.value = value,
                      )),
                  const SizedBox(height: 24),
                  Obx(() => ElevatedButton(
                        onPressed: controller.isCreating.value
                            ? null
                            : () {
                                if (!formKey.currentState!.validate()) {
                                  return;
                                }

                                controller.createEvent(
                                  title: titleController.text,
                                  description: descriptionController.text,
                                  type: type.value,
                                  startDate: startDate.value,
                                  endDate: endDate.value,
                                  coverImage: coverImageController.text,
                                  maxParticipants: int.tryParse(
                                        maxParticipantsController.text.trim(),
                                      ) ??
                                      0,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8906),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: controller.isCreating.value
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Create Event',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label, hint: hint),
    );
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF1A1A2E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _dateTile({
    required BuildContext context,
    required String label,
    required DateTime value,
    required ValueChanged<DateTime> onSelect,
    DateTime? firstDate,
  }) {
    return ListTile(
      tileColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      subtitle: Text(_formatDate(value.toIso8601String()), style: const TextStyle(color: Colors.grey)),
      trailing: const Icon(Icons.calendar_today, color: Color(0xFFFF8906)),
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: firstDate ?? DateTime.now(),
          lastDate: DateTime(2100),
        );

        if (pickedDate == null) {
          return;
        }

        onSelect(DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          value.hour,
          value.minute,
        ));
      },
    );
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) {
      return 'Date unavailable';
    }

    final parsedDate = DateTime.tryParse(rawDate);
    if (parsedDate == null) {
      return rawDate;
    }

    final month = _monthName(parsedDate.month);
    final day = parsedDate.day.toString().padLeft(2, '0');
    return '$day $month ${parsedDate.year}';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _labelize(String value) {
    return value
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}
