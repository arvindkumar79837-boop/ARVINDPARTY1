// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/home/presentation/views/home_screen.dart
// ARVIND PARTY - HOME SCREEN (Banner + Categories + 6 Room Sections + Search)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../controllers/home_controller.dart';
import '../widgets/banner_slider.dart';
import '../widgets/category_grid.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/room_section_card.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        title: const Text('Arvind Party',
            style: TextStyle(
                color: Color(0xFFFF8906),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2)),
        backgroundColor: const Color(0xFF15141F),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white70),
            onPressed: () => Get.toNamed(AppRoutes.notifications),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white70),
            onPressed: () => Get.toNamed(AppRoutes.profile),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.banners.isEmpty) {
          return const _HomeLoadingShimmer();
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              HomeSearchBar(),
              BannerSlider(),
              const SizedBox(height: 16),
              CategoryGrid(),
              const SizedBox(height: 8),
              RoomSectionCard(
                title: 'Recommended Rooms',
                rooms: controller.recommendedRooms,
                onViewAll: () => Get.toNamed(AppRoutes.rooms, arguments: {'type': 'recommended'}),
              ),
              RoomSectionCard(
                title: 'Trending Rooms',
                rooms: controller.trendingRooms,
                onViewAll: () => Get.toNamed(AppRoutes.rooms, arguments: {'type': 'trending'}),
              ),
              RoomSectionCard(
                title: 'New Rooms',
                rooms: controller.newRooms,
                onViewAll: () => Get.toNamed(AppRoutes.rooms, arguments: {'type': 'new'}),
              ),
              RoomSectionCard(
                title: 'Official Rooms',
                rooms: controller.officialRooms,
                onViewAll: () => Get.toNamed(AppRoutes.rooms, arguments: {'type': 'official'}),
              ),
              RoomSectionCard(
                title: 'Family Rooms',
                rooms: controller.familyRooms,
                onViewAll: () => Get.toNamed(AppRoutes.rooms, arguments: {'type': 'family'}),
              ),
              RoomSectionCard(
                title: 'Agency Rooms',
                rooms: controller.agencyRooms,
                onViewAll: () => Get.toNamed(AppRoutes.rooms, arguments: {'type': 'agency'}),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHIMMER LOADING SKELETON
// ─────────────────────────────────────────────────────────────────────────────

class _HomeLoadingShimmer extends StatefulWidget {
  const _HomeLoadingShimmer();

  @override
  State<_HomeLoadingShimmer> createState() => _HomeLoadingShimmerState();
}

class _HomeLoadingShimmerState extends State<_HomeLoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final opacity = _animation.value;
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _ShimmerBox(width: double.infinity, height: 48, opacity: opacity, radius: 24),
              const SizedBox(height: 20),
              _ShimmerBox(width: double.infinity, height: 180, opacity: opacity, radius: 16),
              const SizedBox(height: 20),
              _ShimmerBox(width: 140, height: 24, opacity: opacity, radius: 4),
              const SizedBox(height: 12),
              Row(
                children: [
                  _ShimmerBox(width: 80, height: 80, opacity: opacity, radius: 12),
                  const SizedBox(width: 12),
                  _ShimmerBox(width: 80, height: 80, opacity: opacity, radius: 12),
                  const SizedBox(width: 12),
                  _ShimmerBox(width: 80, height: 80, opacity: opacity, radius: 12),
                  const SizedBox(width: 12),
                  _ShimmerBox(width: 80, height: 80, opacity: opacity, radius: 12),
                ],
              ),
              const SizedBox(height: 24),
              _ShimmerBox(width: 160, height: 20, opacity: opacity, radius: 4),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, __) => _ShimmerBox(width: 140, height: 160, opacity: opacity, radius: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double opacity;
  final double radius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.opacity,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
