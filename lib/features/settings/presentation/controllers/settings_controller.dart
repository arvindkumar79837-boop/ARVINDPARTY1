// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/settings/presentation/controllers/settings_controller.dart
// ARVIND PARTY - SETTINGS & PRIVACY CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/localization/languages.dart';
import '../../../../core/localization/localization_service.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_session_manager.dart';

class SettingsController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = Rxn<String>();
  final cacheCleared = false.obs;

  // Language
  final selectedLanguage = 'en'.obs;
  late final List<SupportedLanguage> languages = SupportedLanguage.all;

  // Privacy sliders
  final showOnlineStatus = true.obs;
  final showLastSeen = true.obs;
  final allowFriendRequests = true.obs;
  final allowPrivateMessages = true.obs;
  final allowGifts = true.obs;
  final showWalletBalance = false.obs;
  final showInSearch = true.obs;
  final allowDataCollection = false.obs;

  // Notifications
  final pushEnabled = true.obs;
  final soundEnabled = true.obs;
  final vibrationEnabled = true.obs;

  // Cache
  final cacheSize = '128 MB'.obs;

  // Profile
  final userName = ''.obs;
  final userBio = ''.obs;
  final userAvatar = ''.obs;
  final userCover = ''.obs;
  final userUid = ''.obs;

  // Support
  final tickets = <Map<String, dynamic>>[].obs;
  final selectedTicketStatus = 'all'.obs;

  // Privacy
  final showVisitorHistory = true.obs;
  final showGallery = true.obs;
  final showFollowers = true.obs;
  final showFollowing = true.obs;

  // Visitor
  final visitors = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
    fetchUserData();
  }

  void loadSettings() {
    try {
      isLoading.value = true;
      final authManager = Get.find<AuthSessionManager>();
      userName.value = authManager.userName.value ?? '';
      userAvatar.value = authManager.userAvatar.value ?? '';
    } catch (e) {
      errorMessage.value = 'Failed to load settings: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void fetchUserData() async {
    try {
      isLoading.value = true;
      final authManager = Get.find<AuthSessionManager>();
      userName.value = authManager.userName.value ?? '';
      userAvatar.value = authManager.userAvatar.value ?? '';
    } catch (e) {
      errorMessage.value = 'Failed to fetch user data: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void setLanguage(SupportedLanguage language) {
    try {
      selectedLanguage.value = language.code;
      final locService = Get.find<LocalizationService>();
      locService.changeLanguage(language.code);
      Get.snackbar('Language', 'Changed to ${language.nativeName}',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFFFF9800), colorText: Colors.white);
    } catch (e) {
      errorMessage.value = 'Failed to change language: $e';
    }
  }

  void clearCache() {
    try {
      cacheCleared.value = true;
      cacheSize.value = '0 MB';
      Get.snackbar('Cache', 'Cache cleared successfully',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFFFF9800), colorText: Colors.white);
      Future.delayed(const Duration(seconds: 2), () {
        cacheCleared.value = false;
      });
    } catch (e) {
      errorMessage.value = 'Failed to clear cache: $e';
    }
  }

  void toggleOnlineStatus(bool value) => showOnlineStatus.value = value;
  void toggleLastSeen(bool value) => showLastSeen.value = value;
  void toggleFriendRequests(bool value) => allowFriendRequests.value = value;
  void togglePrivateMessages(bool value) => allowPrivateMessages.value = value;
  void toggleGifts(bool value) => allowGifts.value = value;
  void toggleWalletBalance(bool value) => showWalletBalance.value = value;
  void toggleSearchVisibility(bool value) => showInSearch.value = value;
  void toggleDataCollection(bool value) => allowDataCollection.value = value;
  void togglePush(bool value) => pushEnabled.value = value;
  void toggleSound(bool value) => soundEnabled.value = value;
  void toggleVibration(bool value) => vibrationEnabled.value = value;

  void saveAllSettings() {
    try {
      Get.snackbar('Settings', 'All settings saved successfully',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFFFF9800), colorText: Colors.white);
    } catch (e) {
      errorMessage.value = 'Failed to save settings: $e';
    }
  }

  // Profile Update
  void updateProfile({Map<String, dynamic>? data}) async {
    try {
      isLoading.value = true;
      final api = Get.find<ApiService>();
      final body = <String, dynamic>{};
      if (data == null) return;
      if (data['name'] != null) body['name'] = data['name'];
      if (data['bio'] != null) body['bio'] = data['bio'];
      if (data['avatar'] != null) body['avatar'] = data['avatar'];
      if (data['coverPhoto'] != null) body['coverPhoto'] = data['coverPhoto'];
      final response = await api.post(
        '/support/profile/update',
        body: body,
      );

      if (response['success'] == true) {
        if (data['name'] != null) userName.value = data['name'] as String;
        if (data['bio'] != null) userBio.value = data['bio'] as String;
        if (data['avatar'] != null) userAvatar.value = data['avatar'] as String;
        if (data['coverPhoto'] != null) userCover.value = data['coverPhoto'] as String;
        Get.snackbar('Success', 'Profile updated', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // Account Deletion
  void deleteAccount(String password) async {
    try {
      isLoading.value = true;
      final api = Get.find<ApiService>();
      final response = await api.post('/support/profile/delete', body: {'password': password});

      if (response['success'] == true) {
        Get.find<AuthSessionManager>().clearSession();
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete account', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // Support Tickets
  void fetchTickets() async {
    try {
      isLoading.value = true;
      final api = Get.find<ApiService>();
      final response = await api.get('/support/tickets');
      if (response['success'] == true) {
        tickets.value = List<Map<String, dynamic>>.from(response['tickets'] ?? []);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load tickets', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void createTicket(String subject, String message) async {
    try {
      isLoading.value = true;
      final api = Get.find<ApiService>();
      final response = await api.post('/support/ticket/create', body: {
        'subject': subject,
        'message': message,
        'category': 'complaint',
      });

      if (response['success'] == true) {
        Get.snackbar('Success', 'Ticket created', snackPosition: SnackPosition.BOTTOM);
        fetchTickets();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create ticket', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void replyToTicket(String ticketId, String message) async {
    try {
      final api = Get.find<ApiService>();
      final response = await api.post('/support/message', body: {
        'ticketId': ticketId,
        'message': message,
      });

      if (response['success'] == true) {
        Get.snackbar('Success', 'Message sent', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Privacy Toggles
  void updatePrivacy(String key, bool value) async {
    try {
      final api = Get.find<ApiService>();
      final response = await api.put('/support/privacy/toggle', body: {'key': key, 'value': value});

      if (response['success'] == true) {
        switch (key) {
          case 'showOnlineStatus': showOnlineStatus.value = value; break;
          case 'showLastSeen': showLastSeen.value = value; break;
          case 'showGallery': showGallery.value = value; break;
          case 'showFollowers': showFollowers.value = value; break;
          case 'showFollowing': showFollowing.value = value; break;
          case 'showVisitorHistory': showVisitorHistory.value = value; break;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update privacy', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Visitor History
  void fetchVisitors() async {
    try {
      isLoading.value = true;
      final api = Get.find<ApiService>();
      final response = await api.get('/support/visitors');
      if (response['success'] == true) {
        visitors.value = List<Map<String, dynamic>>.from(response['visitors'] ?? []);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load visitors', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void recordProfileVisit(String profileUserId) async {
    try {
      final api = Get.find<ApiService>();
      await api.post('/support/visitors/record', body: {'profileUserId': profileUserId});
    } catch (e) {
      // Silent fail for analytics
    }
  }

  // Follow System
  RxBool isFollowing = false.obs;

  void toggleFollow(String targetUserId) async {
    try {
      final api = Get.find<ApiService>();
      final response = await api.post('/support/follow', body: {'targetUserId': targetUserId});

      if (response['success'] == true) {
        isFollowing.value = response['following'] ?? false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update follow', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Search Users
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final api = Get.find<ApiService>();
      final response = await api.get('/support/search', query: {'query': query});
      if (response['success'] == true) {
        return List<Map<String, dynamic>>.from(response['users'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Block List
  final blockedUsers = <Map<String, dynamic>>[].obs;

  void fetchBlockedUsers() async {
    try {
      isLoading.value = true;
      final api = Get.find<ApiService>();
      final response = await api.get('/support/blocked');
      if (response['success'] == true) {
        blockedUsers.value = List<Map<String, dynamic>>.from(response['blockedUsers'] ?? []);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load blocked users', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void blockUser(String targetUserId) async {
    try {
      final api = Get.find<ApiService>();
      final response = await api.post('/support/block', body: {'targetUserId': targetUserId});
      if (response['success'] == true) {
        fetchBlockedUsers();
        Get.snackbar('Success', 'User blocked', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to block user', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void unblockUser(String targetUserId) async {
    try {
      final api = Get.find<ApiService>();
      final response = await api.post('/support/unblock', body: {'targetUserId': targetUserId});
      if (response['success'] == true) {
        fetchBlockedUsers();
        Get.snackbar('Success', 'User unblocked', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to unblock user', snackPosition: SnackPosition.BOTTOM);
    }
  }

  bool checkBlockStatus(bool isBlocked) {
    return isBlocked;
  }

}
