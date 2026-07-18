// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/home/presentation/views/tabs/explore_tab.dart
// ARVIND PARTY - EXPLORE TAB (Search + Trending Categories + Lazy List)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../room/models/room_models.dart';
import '../../../../../core/services/api_service.dart';
import '../../controllers/home_controller.dart';
import '../../widgets/room_card_widget.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  final HomeController ctrl = Get.find<HomeController>();
  final ApiService _api = Get.find<ApiService>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;
  final RxList<Map<String, dynamic>> _searchResults = <Map<String, dynamic>>[].obs;
  final RxBool _isSearching = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxInt _currentPage = 1.obs;
  bool _hasMore = true;

  static const _pageSize = 20;

  static const _trendingCategories = [
    {'name': 'Music', 'icon': '🎵', 'color': '#FF6B6B'},
    {'name': 'Party', 'icon': '🎉', 'color': '#FF8906'},
    {'name': 'Gaming', 'icon': '🎮', 'color': '#6C63FF'},
    {'name': 'Dating', 'icon': '❤️', 'color': '#FF4081'},
    {'name': 'Chat', 'icon': '💬', 'color': '#00BCD4'},
    {'name': 'Comedy', 'icon': '😂', 'color': '#FFD54F'},
    {'name': 'Talk Show', 'icon': '🎙️', 'color': '#81C784'},
    {'name': 'Study', 'icon': '📚', 'color': '#7986CB'},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore.value &&
        _hasMore) {
      _loadMore();
    }
  }

  void _onSearch(String query) {
    _searchQuery.value = query;
    if (query.trim().isEmpty) {
      _searchResults.clear();
      _currentPage.value = 1;
      _hasMore = true;
      return;
    }
    _currentPage.value = 1;
    _hasMore = true;
    _performSearch(query);
  }

  Future<void> _performSearch(String query) async {
    _isSearching.value = true;
    try {
      final response = await _api.get(
        'rooms/search',
        query: {'q': query, 'page': 1, 'limit': _pageSize},
      );
      if (response != null && response['success'] == true) {
        final data = List<Map<String, dynamic>>.from(response['data'] ?? []);
        _searchResults.assignAll(data);
        _hasMore = data.length >= _pageSize;
        _currentPage.value = 1;
      }
    } finally {
      _isSearching.value = false;
    }
  }

  Future<void> _loadMore() async {
    if (_searchQuery.value.isEmpty) return;
    _isLoadingMore.value = true;
    try {
      _currentPage.value++;
      final response = await _api.get(
        'rooms/search',
        query: {
          'q': _searchQuery.value,
          'page': _currentPage.value,
          'limit': _pageSize,
        },
      );
      if (response != null && response['success'] == true) {
        final data = List<Map<String, dynamic>>.from(response['data'] ?? []);
        _searchResults.addAll(data);
        _hasMore = data.length >= _pageSize;
      }
    } catch (e) {
      _currentPage.value--;
    } finally {
      _isLoadingMore.value = false;
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _searchQuery.value = '';
    _searchResults.clear();
    _currentPage.value = 1;
    _hasMore = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            const _ExploreHeader(),

            // ── Search Bar ────────────────────────────────────────────────
            _SearchBarWidget(
              controller: _searchController,
              onChanged: _onSearch,
              onClear: _clearSearch,
            ),

            const SizedBox(height: 4),

            // ── Content ───────────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (_searchQuery.value.isNotEmpty) {
                  return _buildSearchResults();
                }
                return _buildExploreContent();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching.value) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF8906),
          strokeWidth: 2,
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return const _EmptyState(
        icon: Icons.search_off,
        title: 'No results found',
        subtitle: 'Try a different search term',
      );
    }

    return RefreshIndicator(
      color: const Color(0xFFFF8906),
      backgroundColor: const Color(0xFF15141F),
      onRefresh: () async => _performSearch(_searchQuery.value),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
        physics: const BouncingScrollPhysics(),
        itemCount: _searchResults.length + (_hasMore ? 1 : 0),
        itemBuilder: (_, i) {
          if (i >= _searchResults.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFF8906),
                  strokeWidth: 2,
                ),
              ),
            );
          }
          return RoomCardWidget(
            room: RoomModel.fromJson(_searchResults[i]),
          );
        },
      ),
    );
  }

  Widget _buildExploreContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Trending Categories ────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Text(
              'Trending Categories',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _trendingCategories.length,
              itemBuilder: (_, i) {
                final cat = _trendingCategories[i];
                return _TrendingCategoryCard(
                  name: cat['name']!,
                  icon: cat['icon']!,
                  colorHex: cat['color']!,
                  onTap: () {
                    _searchController.text = cat['name']!;
                    _onSearch(cat['name']!);
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // ── Featured Rooms Section ─────────────────────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              'Featured Rooms',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Obx(() {
            if (ctrl.isHomeLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFF8906),
                    strokeWidth: 2,
                  ),
                ),
              );
            }

            final allRooms = [
              ...ctrl.trendingRooms,
              ...ctrl.recommendedRooms,
            ];

            if (allRooms.isEmpty) {
              return const _EmptyState(
                icon: Icons.explore_outlined,
                title: 'No rooms to explore',
                subtitle: 'Check back later for trending content',
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.82,
              ),
              itemCount: allRooms.length,
              itemBuilder: (_, i) => RoomCardWidget(
                room: RoomModel.fromJson({
                  'id': allRooms[i].id,
                  'name': allRooms[i].name,
                  'title': allRooms[i].name,
                  'seatCount': 12,
                  'onlineUsers': allRooms[i].memberCount,
                  'roomType': 'public',
                  'coverImage': allRooms[i].imageUrl,
                }),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _ExploreHeader extends StatelessWidget {
  const _ExploreHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Text(
            'Explore',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.explore, color: Color(0xFFFF8906), size: 20),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEARCH BAR
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBarWidget({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF15141F),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.search, color: Colors.white38, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search rooms, topics, people...',
                  hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
                  isDense: true,
                ),
              ),
            ),
            GestureDetector(
              onTap: onClear,
              child: const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.cancel, color: Colors.white24, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TRENDING CATEGORY CARD
// ─────────────────────────────────────────────────────────────────────────────

class _TrendingCategoryCard extends StatelessWidget {
  final String name;
  final String icon;
  final String colorHex;
  final VoidCallback onTap;

  const _TrendingCategoryCard({
    required this.name,
    required this.icon,
    required this.colorHex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse('0xFF${colorHex.replaceAll('#', '')}'));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white12, size: 64),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white24, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
