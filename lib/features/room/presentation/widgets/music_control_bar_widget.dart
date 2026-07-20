import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';

class MusicControlBar extends StatefulWidget {
  final String roomId;
  final bool isHost;

  const MusicControlBar({super.key, required this.roomId, this.isHost = false});

  @override
  State<MusicControlBar> createState() => _MusicControlBarState();
}

class _MusicControlBarState extends State<MusicControlBar> {
  final _api = Get.find<ApiService>();
  String _title = '';
  String _url = '';
  bool _isPlaying = false;
  DateTime? _startedAt;
  String _lyricsUrl = '';
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchCurrentTrack();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchCurrentTrack());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchCurrentTrack() async {
    try {
      final resp = await _api.dio.get('/luxury/rooms/${widget.roomId}/music/current');
      if (resp.data['success'] == true) {
        final track = resp.data['data'];
        if (mounted) {
          setState(() {
            _title = track?['title'] ?? '';
            _url = track?['url'] ?? '';
            _isPlaying = track?['isPlaying'] ?? false;
            _startedAt = track?['startedAt'] != null ? DateTime.tryParse(track['startedAt']) : null;
            _lyricsUrl = track?['lyricsUrl'] ?? '';
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _api.dio.post('/luxury/rooms/${widget.roomId}/music/pause');
    } else {
      await _api.dio.post('/luxury/rooms/${widget.roomId}/music/play', data: {
        'title': _title.isEmpty ? 'Room Music' : _title,
        'url': _url,
        'lyricsUrl': _lyricsUrl,
      });
    }
    await _fetchCurrentTrack();
  }

  @override
  Widget build(BuildContext context) {
    if (_title.isEmpty && !_isPlaying) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          // Music icon animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _isPlaying ? const Color(0xFFFF8906) : Colors.white12,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _isPlaying ? Icons.music_note : Icons.music_off,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _title,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_startedAt != null)
                  Text(
                    'Started ${_formatDuration(DateTime.now().difference(_startedAt!))} ago',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
              ],
            ),
          ),
          if (widget.isHost)
            IconButton(
              onPressed: _togglePlay,
              icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, color: const Color(0xFFFF8906), size: 32),
            ),
          if (_lyricsUrl.isNotEmpty)
            IconButton(
              onPressed: () => _showLyrics(),
              icon: const Icon(Icons.lyrics_outlined, color: Colors.white70, size: 22),
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inMinutes >= 60) return '${d.inHours}h ${d.inMinutes % 60}m';
    if (d.inSeconds >= 60) return '${d.inMinutes}m ${d.inSeconds % 60}s';
    return '${d.inSeconds}s';
  }

  void _showLyrics() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('🎤 $_title', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Expanded(
              child: Center(
                child: Text(
                  'Lyrics will appear here...\n(LRC format supported)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
