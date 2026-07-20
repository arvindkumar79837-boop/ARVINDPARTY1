import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/moments_controller.dart';

class MomentsFeedTab extends GetView<MomentsController> {
  const MomentsFeedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Text('Feed', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  // Feed toggle
                  Obx(() => Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        _buildToggle('Global', !controller.isFollowingFeed.value, () => controller.setFeedMode(false)),
                        _buildToggle('Following', controller.isFollowingFeed.value, () => controller.setFeedMode(true)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            // Posts
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8906)));
                }
                if (controller.posts.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.dynamic_feed_outlined, color: Colors.white24, size: 64),
                        SizedBox(height: 16),
                        Text('No posts yet', style: TextStyle(color: Colors.white38, fontSize: 16)),
                        SizedBox(height: 8),
                        Text('Be the first to share a moment!', style: TextStyle(color: Colors.white24, fontSize: 13)),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => controller.fetchPosts(),
                  color: const Color(0xFFFF8906),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: controller.posts.length,
                    itemBuilder: (ctx, i) => _buildPostCard(controller.posts[i]),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostSheet(context),
        backgroundColor: const Color(0xFFFF8906),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildToggle(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFF8906) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.white54, fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final isLiked = post['isLiked'] == true;
    final images = (post['images'] as List?) ?? (post['mediaUrls'] as List?) ?? [];
    final commentsCount = post['commentsCount'] ?? 0;
    final likesCount = post['likesCount'] ?? 0;
    final createdAt = post['createdAt'] != null ? DateTime.tryParse(post['createdAt']) : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User row
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFFF8906).withOpacity(0.2),
                backgroundImage: (post['userAvatar'] != null && (post['userAvatar'] as String).isNotEmpty)
                    ? NetworkImage(post['userAvatar'])
                    : null,
                child: (post['userAvatar'] == null || (post['userAvatar'] as String).isEmpty)
                    ? Text((post['userName'] ?? '?')[0].toUpperCase(), style: const TextStyle(color: Color(0xFFFF8906), fontWeight: FontWeight.bold))
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post['userName'] ?? 'Unknown', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(
                      createdAt != null ? _formatTime(createdAt) : '',
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert, color: Colors.white38, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Content
          Text(post['content'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
          // Images
          if (images.isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: PageView.builder(
                  itemCount: images.length,
                  itemBuilder: (ctx, i) => Image.network(images[i], fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.white10, child: const Icon(Icons.broken_image, color: Colors.white24)),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          // Actions
          Row(
            children: [
              GestureDetector(
                onTap: () => controller.likePost(post['_id'] ?? post['id']),
                child: Row(
                  children: [
                    Icon(isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.white54, size: 20),
                    const SizedBox(width: 4),
                    Text('$likesCount', style: const TextStyle(color: Colors.white54, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () => _showCommentsSheet(post),
                child: const Row(
                  children: [
                    Icon(Icons.comment_outlined, color: Colors.white54, size: 20),
                    SizedBox(width: 4),
                  ],
                ),
              ),
              Text('$commentsCount', style: const TextStyle(color: Colors.white54, fontSize: 13)),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.share_outlined, color: Colors.white54, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  void _showCreatePostSheet(BuildContext context) {
    final contentCtrl = TextEditingController();
    Get.bottomSheet(
      Container(
        height: Get.height * 0.5,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Create Post', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: contentCtrl,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "What's on your mind?",
                  hintStyle: const TextStyle(color: Colors.white30),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.photo_camera, color: Colors.white54)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.image, color: Colors.white54)),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    if (contentCtrl.text.trim().isEmpty) return;
                    await controller.createPost(contentCtrl.text.trim());
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8906)),
                  child: const Text('Post', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showCommentsSheet(Map<String, dynamic> post) {
    final commentCtrl = TextEditingController();
    final comments = (post['comments'] as List?) ?? [];
    Get.bottomSheet(
      Container(
        height: Get.height * 0.5,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Text('Comments (${comments.length})', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: comments.isEmpty
                  ? const Center(child: Text('No comments yet', style: TextStyle(color: Colors.white30)))
                  : ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (ctx, i) {
                        final c = comments[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.white12,
                                child: Text((c['userName'] ?? '?')[0].toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c['userName'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                                    Text(c['content'] ?? c['text'] ?? '', style: const TextStyle(color: Colors.white54, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const Divider(color: Colors.white12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      hintStyle: const TextStyle(color: Colors.white30),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () async {
                    if (commentCtrl.text.trim().isEmpty) return;
                    await controller.addComment(post['_id'] ?? post['id'], commentCtrl.text.trim());
                    commentCtrl.clear();
                    Get.back();
                  },
                  icon: const Icon(Icons.send, color: Color(0xFFFF8906)),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
