import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/singing_room_controller.dart';

class SongSearchScreen extends StatelessWidget {
  const SongSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SingingRoomController>();
    final searchCtrl = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0E17),
        title: const Text('Choose a Song', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: searchCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search songs...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onChanged: (v) => ctrl.searchSongs(v),
            ),
          ),
          // Results
          Expanded(
            child: Obx(() {
              if (ctrl.isSearching.value) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFFF6B9D)));
              }
              if (ctrl.searchResults.isEmpty) {
                return Center(
                  child: Text(
                    'Search for a song to sing',
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: ctrl.searchResults.length,
                itemBuilder: (ctx, i) {
                  final song = ctrl.searchResults[i];
                  return _songTile(ctrl, song);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _songTile(SingingRoomController ctrl, Map<String, dynamic> song) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 48,
            height: 48,
            color: const Color(0xFFFF6B9D).withOpacity(0.2),
            child: song['coverImageUrl'] != null && (song['coverImageUrl'] as String).isNotEmpty
                ? Image.network(song['coverImageUrl'], fit: BoxFit.cover)
                : const Icon(Icons.music_note, color: Color(0xFFFF6B9D), size: 24),
          ),
        ),
        title: Text(song['title'] ?? 'Untitled', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: Text(song['artist'] ?? '', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFF6B9D), Color(0xFFFF1493)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('Sing', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
        onTap: () => _confirmJoin(ctrl, song),
      ),
    );
  }

  void _confirmJoin(SingingRoomController ctrl, Map<String, dynamic> song) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: Text('Sing "${song['title']}"?', style: const TextStyle(color: Colors.white)),
        content: Text(
          'You will join the Sing Next queue.\nArtist: ${song['artist'] ?? 'Unknown'}\nDuration: ${_formatDuration(song['durationSeconds'] ?? 0)}',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () => ctrl.joinQueue(song['_id']),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B9D)),
            child: const Text('Join Queue', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
