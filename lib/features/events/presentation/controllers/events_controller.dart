// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/events/presentation/controllers/events_controller.dart
// ARVIND PARTY - EVENTS CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../repositories/events_repository.dart';

class EventsController extends GetxController {
  EventsController({EventsRepository? eventsRepository})
      : _repo = eventsRepository ?? EventsRepository();

  final isLoading = false.obs;
  final isCreating = false.obs;
  final events = <Map<String, dynamic>>[].obs;
  final selectedType = ''.obs;
  final selectedStatus = ''.obs;
  final errorMessage = RxnString();

  final EventsRepository _repo;

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      final result = await _repo.fetchEvents(
        type: selectedType.value.isEmpty ? null : selectedType.value,
        status: selectedStatus.value.isEmpty ? null : selectedStatus.value,
      );
      events.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to load events');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createEvent({
    required String title,
    required String description,
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    String? coverImage,
    int maxParticipants = 0,
  }) async {
    if (title.trim().isEmpty || description.trim().isEmpty) {
      Get.snackbar('Error', 'Title and description are required');
      return;
    }

    if (endDate.isBefore(startDate)) {
      Get.snackbar('Error', 'End date must be after start date');
      return;
    }

    try {
      isCreating.value = true;
      final createdEvent = await _repo.createEvent(
        title: title.trim(),
        description: description.trim(),
        type: type,
        startDate: startDate,
        endDate: endDate,
        coverImage: coverImage?.trim(),
        maxParticipants: maxParticipants,
      );

      events.insert(0, createdEvent);
      Get.back();
      Get.snackbar('Success', 'Event created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create event: ${e.toString()}');
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> applyFilters({
    String? type,
    String? status,
  }) async {
    selectedType.value = type ?? '';
    selectedStatus.value = status ?? '';
    await fetchEvents();
  }
}
