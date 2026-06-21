// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/profile/presentation/controllers/profile_controller.dart
// ARVIND PARTY - UNIFIED PROFILE CONTROLLER (MY PROFILE + OTHER USER PROFILE)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_session_manager.dart';

// ─────────────────────────────────────────────────────────────────────────
// PROFILE CONTROLLER - For current user's profile
// ─────────────────────────────────────────────────────────────────────────

class ProfileController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final AuthSessionManager _session = Get.find<AuthSessionManager>();

  final isLoading = false.obs;
  final userProfile = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final response = await _apiService.get('/profile');
      if (response is Map && response['success'] == true) {
        userProfile.value = Map<String, dynamic>.from(response['data'] ?? response);
      }
    } catch (e) {
      debugPrint('[ProfileController] fetchProfile error: $e');
      userProfile.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      final response = await _apiService.put('/profile', body: data);
      if (response is Map && response['success'] == true) {
        await fetchProfile();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[ProfileController] updateProfile error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  String get userId => _session.userId.value ?? '';
  String get userName => _session.userName.value ?? '';
  String get userAvatar => _session.userAvatar.value ?? '';
}

// ─────────────────────────────────────────────────────────────────────────
// OTHER USER CONTROLLER - For viewing other users' profiles
// ─────────────────────────────────────────────────────────────────────────

class OtherUserController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final userProfile = Rxn<Map<String, dynamic>>();
  final isLoading = false.obs;
  final isFollowing = false.obs;
  final followers = <dynamic>[].obs;
  final following = <dynamic>[].obs;

  Future<void> fetchUserProfile(String userId) async {
    isLoading.value = true;
    try {
      final response = await _apiService.get('/user/$userId/profile');
      if (response is Map && response['success'] == true) {
        userProfile.value = Map<String, dynamic>.from(response['data'] ?? response);
        isFollowing.value = response['isFollowedByMe'] ?? false;
      }
    } catch (e) {
      debugPrint('[OtherUserController] fetchUserProfile error: $e');
      userProfile.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> followUser(String userId) async {
    try {
      final response = await _apiService.post('/user/$userId/follow');
      if (response is Map && response['success'] == true) {
        isFollowing.value = true;
      }
    } catch (e) {
      debugPrint('[OtherUserController] followUser error: $e');
    }
  }

  Future<void> unfollowUser(String userId) async {
    try {
      final response = await _apiService.post('/user/$userId/unfollow');
      if (response is Map && response['success'] == true) {
        isFollowing.value = false;
      }
    } catch (e) {
      debugPrint('[OtherUserController] unfollowUser error: $e');
    }
  }

  Future<void> blockUser(String userId) async {
    try {
      final response = await _apiService.post('/user/$userId/block');
      if (response is Map && response['success'] == true) {
        Get.back();
      }
    } catch (e) {
      debugPrint('[OtherUserController] blockUser error: $e');
    }
  }

  Future<void> fetchFollowers(String userId) async {
    try {
      final response = await _apiService.get('/user/$userId/followers');
      if (response is Map && response['success'] == true) {
        followers.value = response['data'] ?? [];
      }
    } catch (e) {
      debugPrint('[OtherUserController] fetchFollowers error: $e');
    }
  }

  Future<void> fetchFollowing(String userId) async {
    try {
      final response = await _apiService.get('/user/$userId/following');
      if (response is Map && response['success'] == true) {
        following.value = response['data'] ?? [];
      }
    } catch (e) {
      debugPrint('[OtherUserController] fetchFollowing error: $e');
    }
  }
}