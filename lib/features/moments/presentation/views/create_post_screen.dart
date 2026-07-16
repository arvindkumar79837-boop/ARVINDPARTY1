// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/moments/presentation/views/create_post_screen.dart
// ARVIND PARTY - CREATE POST SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/moments_controller.dart';

class CreatePostScreen extends GetView<MomentsController> {
  CreatePostScreen({super.key});

  final _contentController = TextEditingController();
  final _selectedMediaPaths = <String>[].obs;
  final _selectedMediaType = Rxn<String>();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source, maxWidth: 1080, imageQuality: 85);
      if (pickedFile != null) {
        _selectedMediaPaths.add(pickedFile.path);
        _selectedMediaType.value = 'image';
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(seconds: 60));
      if (pickedFile != null) {
        _selectedMediaPaths.clear();
        _selectedMediaPaths.add(pickedFile.path);
        _selectedMediaType.value = 'video';
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick video: $e');
    }
  }

  void _submitPost() {
    final content = _contentController.text.trim();
    if (content.isEmpty && _selectedMediaPaths.isEmpty) {
      Get.snackbar('Error', 'Please add some content or media');
      return;
    }

    controller.createPost(
      content: content,
      mediaType: _selectedMediaType.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          Obx(() => TextButton(
            onPressed: controller.isCreating.value ? null : _submitPost,
            child: controller.isCreating.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF8906)),
                  )
                : const Text('Post', style: TextStyle(color: Color(0xFFFF8906), fontWeight: FontWeight.bold)),
          )),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _contentController,
              maxLines: 8,
              minLines: 4,
              style: const TextStyle(color: Colors.white),
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF2D2D44),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Selected media preview
            Obx(() {
              if (_selectedMediaPaths.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedMediaPaths.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFF2D2D44),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _selectedMediaType.value == 'video'
                              ? const Icon(Icons.videocam, color: Colors.white54, size: 40)
                              : Image.file(File(_selectedMediaPaths[index]), fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 4,
                          right: 12,
                          child: GestureDetector(
                            onTap: () => _selectedMediaPaths.removeAt(index),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            }),

            const SizedBox(height: 16),

            // Media picker buttons
            Row(
              children: [
                _buildMediaButton(Icons.photo_camera, 'Photo', () => _pickImage(ImageSource.camera)),
                const SizedBox(width: 12),
                _buildMediaButton(Icons.photo_library, 'Gallery', () => _pickImage(ImageSource.gallery)),
                const SizedBox(width: 12),
                _buildMediaButton(Icons.videocam, 'Video', _pickVideo),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D44),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFFF8906), size: 20),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
