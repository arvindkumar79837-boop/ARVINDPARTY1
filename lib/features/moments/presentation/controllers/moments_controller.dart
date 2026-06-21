// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/moments/presentation/controllers/moments_controller.dart
// ARVIND PARTY - MOMENTS CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../repositories/moments_repository.dart';

class MomentsController extends GetxController {
  final isLoading = false.obs;
  final isCreating = false.obs;
  final posts = <Map<String, dynamic>>[].obs;

  final MomentsRepository _repo = MomentsRepository();

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      isLoading.value = true;
      final result = await _repo.fetchPosts();
      posts.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load moments');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createPost({
    required String content,
    List<String>? mediaUrls,
    String? mediaType,
  }) async {
    try {
      isCreating.value = true;
      final result = await _repo.createPost(
        content: content,
        mediaUrls: mediaUrls,
        mediaType: mediaType,
      );

      if (result['success'] == true) {
        final newPost = result['data'] as Map<String, dynamic>?;
        if (newPost != null) {
          posts.insert(0, newPost);
        }
        Get.back();
        Get.snackbar('Success', 'Post created successfully');
      } else {
        Get.snackbar('Error', result['message'] ?? 'Failed to create post');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create post');
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> likePost(String postId) async {
    try {
      await _repo.likePost(postId);
      final index = posts.indexWhere((p) => p['_id'] == postId || p['id'] == postId);
      if (index != -1) {
        final currentLikes = posts[index]['likesCount'] as int? ?? 0;
        posts[index] = {...posts[index], 'likesCount': currentLikes + 1, 'isLiked': true};
        posts.refresh();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to like post');
    }
  }

  Future<void> addComment(String postId, String text) async {
    try {
      final result = await _repo.addComment(postId, text);
      if (result['success'] == true) {
        final index = posts.indexWhere((p) => p['_id'] == postId || p['id'] == postId);
        if (index != -1) {
          final currentComments = posts[index]['commentsCount'] as int? ?? 0;
          posts[index] = {...posts[index], 'commentsCount': currentComments + 1};
          posts.refresh();
        }
        Get.snackbar('Success', 'Comment added');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to add comment');
    }
  }
}
