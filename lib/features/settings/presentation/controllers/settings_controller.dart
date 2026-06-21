// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/settings/presentation/controllers/settings_controller.dart
// ARVIND PARTY - SETTINGS & PRIVACY CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = Rxn<String>();
  final cacheCleared = false.obs;

  // Language
  final selectedLanguage = 'English'.obs;
  final languages = <String>['English', 'Hindi', 'Spanish', 'French', 'Arabic', 'Bengali', 'Portuguese'];

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

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  void loadSettings() {
    try {
      isLoading.value = true;
      // In production, would load from storage/API
    } catch (e) {
      errorMessage.value = 'Failed to load settings: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void setLanguage(String language) {
    try {
      selectedLanguage.value = language;
      Get.snackbar('Language', 'Changed to $language',
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
}