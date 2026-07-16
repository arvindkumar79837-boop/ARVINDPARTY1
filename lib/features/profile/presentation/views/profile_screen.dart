// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/profile/presentation/views/profile_screen.dart
// ARVIND PARTY - PROFILE SCREEN (REFACTORED WITH LIVE DATA)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/profile_controller.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Get.to(() => const EditProfileScreen());
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.userProfile.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = controller.userProfile.value;
        if (user == null) {
          return const Center(
            child: Text(
              'Could not load profile.',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                  image: (user.avatar != null && user.avatar!.isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(user.avatar!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (user.avatar == null || user.avatar!.isEmpty)
                    ? const Center(child: Icon(Icons.camera_alt, color: Colors.grey, size: 40))
                    : null,
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: (user.avatar != null && user.avatar!.isNotEmpty)
                            ? NetworkImage(user.avatar!)
                            : null,
                        backgroundColor: const Color(0xFFFF8906),
                        child: (user.avatar == null || user.avatar!.isEmpty)
                            ? Text(
                                user.name?.isNotEmpty == true ? user.name![0].toUpperCase() : '?',
                                style: const TextStyle(fontSize: 40, color: Colors.white),
                              )
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                user.name ?? user.username,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (user.isVerified)
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Icon(Icons.verified, color: Colors.blue, size: 20),
                              ),
                            const SizedBox(width: 8),
                            if (user.vipTier != 'free')
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4AF37),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  user.vipTier.toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.monetization_on, color: Color(0xFFD4AF37), size: 16),
                            const SizedBox(width: 4),
                            Text('${user.coins} coins', style: const TextStyle(color: Color(0xFFD4AF37))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Bio',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                user.bio?.isNotEmpty == true ? user.bio! : 'No bio available.',
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
              ),
              const SizedBox(height: 24),

              _buildInfoRow(Icons.person_outline, 'Gender', user.gender ?? 'Not specified'),
              _buildInfoRow(Icons.cake_outlined, 'Birthday', user.dob?.toString().substring(0, 10) ?? 'Not specified'),
              _buildInfoRow(Icons.numbers, 'User ID', user.arvindId ?? user.id),
              _buildInfoRow(Icons.leaderboard, 'Level', user.level.toString()),
              
              const Divider(height: 32),

              _buildNavigationRow(Icons.link, 'Social Links', () => Get.toNamed(AppRoutes.socialLinks)),
              _buildNavigationRow(Icons.photo_library_outlined, 'Personal Gallery', () => Get.toNamed(AppRoutes.gallery)),
              _buildNavigationRow(Icons.privacy_tip_outlined, 'Privacy Settings', () => Get.toNamed(AppRoutes.privacy)),
              _buildNavigationRow(Icons.block, 'Block List', () => Get.toNamed(AppRoutes.blockList)),
              _buildNavigationRow(Icons.history, 'Visitor History', () => Get.toNamed(AppRoutes.visitorHistory)),

              const Divider(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[400]),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRow(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[400]),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }
}
