import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/friend_model.dart';
import '../repositories/friend_repository.dart';
import '../widgets/friend_tile.dart';

class FriendSearchScreen extends StatefulWidget {
  const FriendSearchScreen({super.key});

  @override
  State<FriendSearchScreen> createState() => _FriendSearchScreenState();
}

class _FriendSearchScreenState extends State<FriendSearchScreen> {
  final _repo = FriendRepository();
  final _searchController = TextEditingController();
  final _results = <FriendModel>[].obs;
  final _isSearching = false.obs;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    _isSearching.value = true;
    try {
      final results = await _repo.searchUsers(query.trim());
      _results.assignAll(results);
    } catch (e) {
      _results.clear();
    } finally {
      _isSearching.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Users'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by username...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _results.clear();
                  },
                ),
              ),
              onSubmitted: _search,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_isSearching.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_results.isEmpty) {
                return const Center(
                  child: Text(
                    'Search for users to follow or add as friends',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _results.length,
                itemBuilder: (context, index) => FriendTile(friend: _results[index]),
              );
            }),
          ),
        ],
      ),
    );
  }
}
