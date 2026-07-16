// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/notifications/presentation/controllers/notifications_controller.dart
// ARVIND PARTY - NOTIFICATIONS CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../repositories/notifications_repository.dart';

class NotificationsController extends GetxController {
  final isLoading = false.obs;
  final notifications = <Map<String, dynamic>>[].obs;

  final NotificationsRepository _notificationsRepository = NotificationsRepository();

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      final result = await _notificationsRepository.fetchNotifications();
      notifications.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load notifications');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationsRepository.markAsRead(notificationId);
      final index = notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        notifications[index] = {...notifications[index], 'read': true};
        notifications.refresh();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark notification as read');
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
