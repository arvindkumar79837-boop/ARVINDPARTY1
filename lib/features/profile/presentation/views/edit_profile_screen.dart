// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/profile/presentation/views/edit_profile_screen.dart
// ARVIND PARTY - EDIT PROFILE SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/profile_controller.dart';

class EditProfileScreen extends GetView<ProfileController> {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameCtrl = TextEditingController(text: controller.userProfile.value?.name ?? '');
    final bioCtrl = TextEditingController(text: controller.userProfile.value?.bio ?? '');
    final genderCtrl = TextEditingController(text: controller.userProfile.value?.gender ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          Obx(() => TextButton(
            onPressed: controller.isLoading.value
                ? null
                : () async {
                    final success = await controller.updateProfile({
                      if (nameCtrl.text.isNotEmpty) 'name': nameCtrl.text.trim(),
                      'bio': bioCtrl.text.trim(),
                      'gender': genderCtrl.text.trim(),
                    });
                    if (success) {
                      Get.back();
                      Get.snackbar('Success', 'Profile updated',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF4CAF50),
                          colorText: Colors.white);
                    } else {
                      Get.snackbar('Error', 'Failed to update profile',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFFF44336),
                          colorText: Colors.white);
                    }
                  },
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF8906)),
                  )
                : const Text('Save', style: TextStyle(color: Color(0xFFFF8906), fontWeight: FontWeight.bold)),
          )),
        ],
      ),
      body: Obx(() {
        final user = controller.userProfile.value;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundImage: (user?.avatar != null && user!.avatar!.isNotEmpty)
                          ? NetworkImage(user.avatar!)
                          : null,
                      backgroundColor: const Color(0xFFFF8906),
                      child: (user?.avatar == null || user!.avatar!.isEmpty)
                          ? Text(
                              user?.name?.isNotEmpty == true ? user!.name![0].toUpperCase() : '?',
                              style: const TextStyle(fontSize: 44, color: Colors.white),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _showImagePickerDialog(controller),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF8906),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => _showImagePickerDialog(controller, isCover: true),
                  child: const Text('Change Cover Photo', style: TextStyle(color: Color(0xFFFF8906))),
                ),
              ),
              const SizedBox(height: 24),

              // Name
              _buildLabel('Name'),
              _buildTextField(controller: nameCtrl, hint: 'Enter your name'),
              const SizedBox(height: 16),

              // Bio
              _buildLabel('Bio'),
              _buildTextField(controller: bioCtrl, hint: 'Tell us about yourself', maxLines: 3),
              const SizedBox(height: 16),

              // Gender
              _buildLabel('Gender'),
              _buildTextField(controller: genderCtrl, hint: 'Male / Female / Other'),
              const SizedBox(height: 16),

              // Read-only info
              if (user?.arvindId != null) ...[
                _buildLabel('Arvind ID'),
                _buildTextField(
                  controller: TextEditingController(text: user!.arvindId),
                  hint: '',
                  enabled: false,
                ),
                const SizedBox(height: 16),
              ],

              if (user?.phone != null) ...[
                _buildLabel('Phone'),
                _buildTextField(
                  controller: TextEditingController(text: user!.phone),
                  hint: '',
                  enabled: false,
                ),
                const SizedBox(height: 16),
              ],

              // Level & Coins display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn('Level', '${user?.level ?? 1}', Icons.leaderboard),
                    _buildStatColumn('Coins', '${user?.coins ?? 0}', Icons.monetization_on),
                    _buildStatColumn('Diamonds', '${user?.diamonds ?? 0}', Icons.diamond),
                    _buildStatColumn('XP', '${user?.xp ?? 0}', Icons.star),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showImagePickerDialog(ProfileController controller, {bool isCover = false}) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text('Camera', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Get.back();
                  final path = await _pickImage(ImageSource.camera);
                  if (path != null) {
                    await controller.uploadProfilePicture(path, isCover: isCover);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text('Gallery', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Get.back();
                  final path = await _pickImage(ImageSource.gallery);
                  if (path != null) {
                    await controller.uploadProfilePicture(path, isCover: isCover);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source, maxWidth: 1080, imageQuality: 85);
      return pickedFile?.path;
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image');
      return null;
    }
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      enabled: enabled,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30),
        filled: true,
        fillColor: const Color(0xFF1E1E2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFFF8906)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white12),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFFF8906), size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
      ],
    );
  }
}
