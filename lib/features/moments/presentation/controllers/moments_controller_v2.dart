import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/moments_repository.dart';

class MomentsControllerV2 extends GetxController {
  final MomentsRepository _repo = MomentsRepository();

  final isLoading = true.obs;
  final isCreating = false.obs;
  final posts = <Map<String, dynamic>>[].obs;
  final isFollowingFeed = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
  }

  void setFeedMode(bool following) {
    isFollowingFeed.value = following;
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      isLoading.value = true;
      final data = await _repo.fetchPosts();
      posts.assignAll(data);
    } catch (e) {
      debugPrint('fetchPosts error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createPost(String content, {List<String>? mediaUrls, String? mediaType}) async {
    try {
      isCreating.value = true;
      final newPost = await _repo.createPost(content, mediaUrls: mediaUrls, mediaType: mediaType);
      if (newPost != null) {
        posts.insert(0, newPost);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create post', backgroundColor: Colors.red.shade900, colorText: Colors.white);
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> likePost(String postId) async {
    try {
      await _repo.likePost(postId);
      final idx = posts.indexWhere((p) => (p['_id'] ?? p['id']) == postId);
      if (idx >= 0) {
        posts[idx]['isLiked'] = true;
        posts[idx]['likesCount'] = (posts[idx]['likesCount'] ?? 0) + 1;
        posts.refresh();
      }
    } catch (e) {
      debugPrint('likePost error: $e');
    }
  }

  Future<void> addComment(String postId, String text) async {
    try {
      await _repo.addComment(postId, text);
      final idx = posts.indexWhere((p) => (p['_id'] ?? p['id']) == postId);
      if (idx >= 0) {
        posts[idx]['commentsCount'] = (posts[idx]['commentsCount'] ?? 0) + 1;
        posts.refresh();
      }
    } catch (e) {
      debugPrint('addComment error: $e');
    }
  }
}
