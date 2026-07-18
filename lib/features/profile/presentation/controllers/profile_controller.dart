// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/profile/presentation/controllers/profile_controller.dart
// ARVIND PARTY - UNIFIED PROFILE CONTROLLER (REFACTORED WITH USER MODEL)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_session_manager.dart';
import '../../../auth/models/auth_model.dart'; // Import the User model

// ─────────────────────────────────────────────────────────────────────────
// PROFILE CONTROLLER - For current user's profile
// ─────────────────────────────────────────────────────────────────────────

class ProfileController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final AuthSessionManager _session = Get.find<AuthSessionManager>();

  final isLoading = false.obs;
  // Use the strongly-typed User model for the user's profile
  final userProfile = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final userId = _session.userId.value;
      if (userId == null || userId.isEmpty) {
        userProfile.value = null;
        return;
      }

      // The API endpoint should provide the full user object
      final response = await _apiService.get('/users/$userId');
      if (response is Map && response['success'] == true) {
        final data = Map<String, dynamic>.from(response['data']);
        // Parse the response directly into our User model
        userProfile.value = User.fromBackendJson(data);
      }
    } catch (e) {
      userProfile.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      final userId = _session.userId.value;
      if (userId == null || userId.isEmpty) return false;
      // The API endpoint might need to be /users/:userId or similar
      final response = await _apiService.put('/users/$userId', body: data);
      if (response is Map && response['success'] == true) {
        await fetchProfile(); // Refresh profile after update
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> uploadProfilePicture(String imagePath, {bool isCover = false}) async {
    try {
      final userId = _session.userId.value;
      final endpoint = isCover ? '/users/$userId/cover-photo' : '/users/$userId/avatar';
      final fieldName = isCover ? 'coverPhoto' : 'avatar';

      final response = await _apiService.uploadFile(endpoint, imagePath, fieldName);
      if (response is Map && response['success'] == true) {
        await fetchProfile(); // Refresh to get new image URL
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  String get userId => _session.userId.value ?? '';

}

// ─────────────────────────────────────────────────────────────────────────
// OTHER USER CONTROLLER - For viewing other users' profiles
// ─────────────────────────────────────────────────────────────────────────

class OtherUserController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final AuthSessionManager _session = Get.find<AuthSessionManager>();

  final userProfile = Rxn<User>();
  final isLoading = false.obs;
  final isFollowing = false.obs;
  final isBlockedByMe = false.obs;

  Future<void> fetchUserProfile(String userId) async {
    isLoading.value = true;
    try {
      // Pass current user's ID to get relationship status (isFollowing, etc.)
      final response = await _apiService.get('/users/$userId', queryParams: {'viewerId': _session.userId.value});
      if (response is Map && response['success'] == true) {
        final data = Map<String, dynamic>.from(response['data']);
        userProfile.value = User.fromBackendJson(data);
        
        // Assuming backend returns these boolean flags based on 'viewerId'
        isFollowing.value = data['isFollowing'] ?? false;
        isBlockedByMe.value = data['isBlockedByMe'] ?? false;
      }
    } catch (e) {
      userProfile.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> followUser(String userId) async {
    try {
      final response = await _apiService.post('/social/follow', body: {'userId': userId});
      if (response is Map && response['success'] == true) {
        isFollowing.value = true;
        userProfile.update((user) {
          user?.followers.add(_session.userId.value!);
        });
      }
    } catch (e) {
    }
  }

  Future<void> unfollowUser(String userId) async {
    try {
      final response = await _apiService.post('/social/unfollow', body: {'userId': userId});
      if (response is Map && response['success'] == true) {
        isFollowing.value = false;
        userProfile.update((user) {
          user?.followers.remove(_session.userId.value!);
        });
      }
    } catch (e) {
    }
  }

  Future<void> blockUser(String userId) async {
    try {
      final response = await _apiService.post('/social/block', body: {'userId': userId});
      if (response is Map && response['success'] == true) {
        isBlockedByMe.value = true;
        Get.back(); // Go back after blocking
      }
    } catch (e) {
    }
  }
}
