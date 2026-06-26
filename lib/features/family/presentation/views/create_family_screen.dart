// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/family/presentation/views/create_family_screen.dart
// ARVIND PARTY - CREATE FAMILY SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/family_controller.dart';

class CreateFamilyScreen extends GetView<FamilyController> {
  const CreateFamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Create Family',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: controller.createFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withValues(alpha: 0.2),
                        Colors.purple.withValues(alpha: 0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade300, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Create your family for 5,000 coins. You must be at least Level 5 to create a family.',
                          style: TextStyle(color: Colors.blue.shade100, fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Family Name
                const Text(
                  'Family Name',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: controller.familyNameController,
                  style: const TextStyle(color: Colors.white),
                  maxLength: 30,
                  decoration: InputDecoration(
                    hintText: 'Enter family name',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    prefixIcon: Icon(Icons.group, color: Colors.grey.shade600),
                    filled: true,
                    fillColor: const Color(0xFF252542),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF8906), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a family name';
                    }
                    if (value.trim().length < 3) {
                      return 'Name must be at least 3 characters';
                    }
                    if (value.trim().length > 30) {
                      return 'Name must be less than 30 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Family Badge
                const Text(
                  'Family Badge (Optional)',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: controller.familyBadgeController,
                  style: const TextStyle(color: Colors.white),
                  maxLength: 20,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'e.g. TEAM_ARVIND_KINGS',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    prefixIcon: Icon(Icons.emoji_events, color: Colors.grey.shade600),
                    filled: true,
                    fillColor: const Color(0xFF252542),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF8906), width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.trim().length > 20) {
                      return 'Badge must be less than 20 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Badge will be displayed next to family name in rankings',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 24),

                // Family Slogan
                const Text(
                  'Family Slogan (Optional)',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: controller.familySloganController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 2,
                  maxLength: 100,
                  decoration: InputDecoration(
                    hintText: 'Enter a catchy slogan for your family',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Icon(Icons.format_quote, color: Colors.grey.shade600),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF252542),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF8906), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This will be displayed on your family profile',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 40),

                // Create Button
                Obx(() {
                  return SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: controller.isCreating.value ? null : controller.createFamily,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF8906), Color(0xFFF6F7F8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF8906).withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: controller.isCreating.value
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'CREATE FAMILY',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}