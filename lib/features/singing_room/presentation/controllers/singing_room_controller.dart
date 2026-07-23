import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../../../core/services/api_service.dart';
import '../../../../core/socket/socket_service.dart';
import '../../../gift/presentation/controllers/gift_controller.dart';

class SingingRoomController extends GetxController {
  final _api = Get.find<ApiService>();
  final _socketService = Get.find<SocketService>();

  final isHost = false.obs;
  final isCoHost = false.obs;
  final roomId = ''.obs;

  // Current performer
  final performerId = Rx<String?>(null);
  final performerName = ''.obs;
  final performerAvatar = ''.obs;
  final currentSong = Rx<Map<String, dynamic>?>(null);
  final performanceStartedAt = Rx<DateTime?>(null);
  final isPerformerMuted = false.obs;

  // Queue
  final micQueue = <Map<String, dynamic>>[].obs;
  final myQueuePosition = (-1).obs;

  // Likes
  final likeCount = 0.obs;
  final isLiking = false.obs;

  // Lyrics
  final currentLyricIndex = 0.obs;
  final lyricsLines = <Map<String, dynamic>>[].obs;

  // Songs
  final searchResults = <Map<String, dynamic>>[].obs;
  final isSearching = false.obs;

  io.Socket? _socket;
  Timer? _likeDebounceTimer;
  Timer? _lyricsTimer;

  @override
  void onInit() {
    super.onInit();
    _connectSocket();
  }

  @override
  void onClose() {
    _lyricsTimer?.cancel();
    _likeDebounceTimer?.cancel();
    // Remove listeners from global socket without disconnecting it
    _socket?.off('singing:next-performer');
    _socket?.off('singing:performance-ended');
    _socket?.off('singing:like-count');
    _socket?.off('singing:queue-updated');
    _socket?.off('singing:queue-joined');
    _socket?.off('singing:sync-response');
    super.onClose();
  }

  void _connectSocket() {
    _socket = _socketService.socket;
    if (_socket == null) return;

    _socket!.on('singing:next-performer', _onNextPerformer);
    _socket!.on('singing:performance-ended', _onPerformanceEnded);
    _socket!.on('singing:like-count', _onLikeCount);
    _socket!.on('singing:queue-updated', _onQueueUpdated);
    _socket!.on('singing:queue-joined', _onQueueJoined);
    _socket!.on('singing:sync-response', _onSyncResponse);
  }

  void initRoom(String id, String userId, String ownerId, List coHostIds) {
    roomId.value = id;
    isHost.value = ownerId == userId;
    isCoHost.value = coHostIds.contains(userId);
    _socket?.emit('join-room', {'roomId': id, 'userId': userId});
    _requestSync();
  }

  void _onNextPerformer(data) {
    performerId.value = data['performerId'];
    currentSong.value = data['song'];
    performanceStartedAt.value = DateTime.parse(data['startedAt']);
    likeCount.value = 0;
    micQueue.removeAt(0);
    _updateMyPosition();
    _startLyricsSync();
    Get.snackbar(
      '🎤 New Performance!',
      '${data['song']?['title'] ?? 'Song'} is now live',
      backgroundColor: const Color(0xFFFF6B9D).withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _onPerformanceEnded(data) {
    performerId.value = null;
    currentSong.value = null;
    performanceStartedAt.value = null;
    _lyricsTimer?.cancel();
    _showSharePrompt(data['totalLikes'] ?? 0);
  }

  void _onLikeCount(data) {
    likeCount.value = data['likeCount'] ?? 0;
  }

  void _onQueueUpdated(data) {
    if (data['removedUserId'] != null) {
      micQueue.removeWhere((e) => e['userId'] == data['removedUserId']);
    }
    _updateMyPosition();
  }

  void _onQueueJoined(data) {
    myQueuePosition.value = data['position'] ?? -1;
  }

  void _onSyncResponse(data) {
    performerId.value = data['performerId'];
    if (data['songId'] != null) _fetchSongDetails(data['songId']);
    performanceStartedAt.value = data['startedAt'] != null ? DateTime.parse(data['startedAt']) : null;
  }

  Future<void> _fetchSongDetails(String songId) async {
    try {
      final resp = await _api.dio.get('/singing/songs?search=$songId');
      final songs = resp.data['data']?['songs'] ?? [];
      if (songs.isNotEmpty) {
        currentSong.value = songs[0];
        _startLyricsSync();
      }
    } catch (e) {
      debugPrint('SingingRoom: _fetchSongDetails failed: $e');
    }
  }

  void _requestSync() {
    _socket?.emit('singing:sync', {'roomId': roomId.value});
  }

  // ─── ACTIONS ───────────────────────────────────────────────────
  Future<void> searchSongs(String query) async {
    if (query.isEmpty) { searchResults.clear(); return; }
    isSearching.value = true;
    try {
      final resp = await _api.dio.get('/singing/songs', queryParameters: {'search': query, 'limit': 30});
      final songs = (resp.data['data']?['songs'] ?? []).cast<Map<String, dynamic>>();
      searchResults.assignAll(songs);
    } catch (e) {
      debugPrint('SingingRoom: searchSongs failed: $e');
    }
    isSearching.value = false;
  }

  Future<void> joinQueue(String songId) async {
    try {
      final resp = await _api.dio.post('/singing/queue/join', data: {'roomId': roomId.value, 'songId': songId});
      if (resp.data['success'] == true) {
        myQueuePosition.value = resp.data['data']['position'] ?? -1;
        Get.back();
        Get.snackbar('Queued!', 'You are #${myQueuePosition.value} in the queue', backgroundColor: const Color(0xFF4CAF50), colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not join queue', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> leaveQueue() async {
    try {
      await _api.dio.post('/singing/queue/leave', data: {'roomId': roomId.value});
      myQueuePosition.value = -1;
      micQueue.removeWhere((e) => e['isMe'] == true);
    } catch (e) {
      debugPrint('SingingRoom: leaveQueue failed: $e');
    }
  }

  Future<void> startPerformance() async {
    try {
      final resp = await _api.dio.post('/singing/performance/start', data: {'roomId': roomId.value});
      if (resp.data['success'] == true) {
        final data = resp.data['data'];
        performerId.value = data['performerId'];
        currentSong.value = data['song'];
        performanceStartedAt.value = DateTime.parse(data['startedAt']);
        likeCount.value = 0;
        _startLyricsSync();
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not start performance', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> endPerformance() async {
    try {
      await _api.dio.post('/singing/performance/end', data: {'roomId': roomId.value});
      performerId.value = null;
      currentSong.value = null;
      performanceStartedAt.value = null;
      _lyricsTimer?.cancel();
    } catch (e) {
      debugPrint('SingingRoom: endPerformance failed: $e');
    }
  }

  void sendLike() {
    if (isLiking.value) return;
    _socket?.emit('singing:like', {'roomId': roomId.value});
    isLiking.value = true;
    _likeDebounceTimer?.cancel();
    _likeDebounceTimer = Timer(const Duration(milliseconds: 200), () => isLiking.value = false);
  }

  void removeUserFromQueue(String targetUserId) {
    _socket?.emit('singing:remove-from-queue', {'roomId': roomId.value, 'targetUserId': targetUserId});
  }

  // ─── LYRICS SYNC ──────────────────────────────────────────────
  void _startLyricsSync() {
    _lyricsTimer?.cancel();
    final lyricsUrl = currentSong.value?['lyricsUrl'] ?? '';
    if (lyricsUrl.isEmpty) return;
    _parseLRC(lyricsUrl);
    _lyricsTimer = Timer.periodic(const Duration(milliseconds: 500), (_) => _updateLyricIndex());
  }

  void _parseLRC(String url) {
    // LRC format: [mm:ss.xx] text
    lyricsLines.clear();
    currentLyricIndex.value = 0;

    // Attempt to fetch LRC content from the URL
    _api.dio.get(url).then((resp) {
      final content = resp.data?.toString() ?? '';
      if (content.isEmpty) return;

      final lines = content.split('\n');
      final parsed = <Map<String, dynamic>>[];
      final regex = RegExp(r'\[(\d+):(\d+\.?\d*)\]\s*(.*)');

      for (final line in lines) {
        final match = regex.firstMatch(line);
        if (match != null) {
          final minutes = int.parse(match.group(1)!);
          final seconds = double.parse(match.group(2)!);
          final text = match.group(3) ?? '';
          parsed.add({
            'timestamp': ((minutes * 60) + seconds) * 1000,
            'text': text,
          });
        }
      }

      if (parsed.isNotEmpty) {
        lyricsLines.assignAll(parsed);
      }
    }).catchError((e) {
      debugPrint('Failed to fetch LRC lyrics: $e');
    });
  }

  void _updateLyricIndex() {
    if (performanceStartedAt.value == null || lyricsLines.isEmpty) return;
    final elapsed = DateTime.now().difference(performanceStartedAt.value!).inMilliseconds;
    for (int i = lyricsLines.length - 1; i >= 0; i--) {
      final ts = lyricsLines[i]['timestamp'] as int? ?? 0;
      if (elapsed >= ts) {
        currentLyricIndex.value = i;
        break;
      }
    }
  }

  void setLyricsData(List<Map<String, dynamic>> lines) {
    lyricsLines.assignAll(lines);
  }

  // ─── SHARE PROMPT ─────────────────────────────────────────────
  void _showSharePrompt(int totalLikes) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text('Performance Ended!', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('You received $totalLikes likes', style: const TextStyle(color: Color(0xFFFF6B9D), fontSize: 18)),
            const SizedBox(height: 16),
            const Text('Share this performance to your Moments feed?', style: TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('No thanks', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () { Get.back(); _sharePerformance(); },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B9D)),
            child: const Text('Share', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _sharePerformance() async {
    try {
      await _api.dio.post('/moments', data: {
        'text': '🎤 Just performed "${currentSong.value?['title'] ?? 'a song'}" in the Singing Room!',
        'type': 'SINGING_PERFORMANCE',
      });
      Get.snackbar('Shared!', 'Your performance is now on Moments', backgroundColor: const Color(0xFF4CAF50), colorText: Colors.white);
    } catch (_) {
      Get.snackbar('Error', 'Could not share', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _updateMyPosition() {
    for (int i = 0; i < micQueue.length; i++) {
      if (micQueue[i]['isMe'] == true) {
        myQueuePosition.value = i + 1;
        return;
      }
    }
    myQueuePosition.value = -1;
  }
}
