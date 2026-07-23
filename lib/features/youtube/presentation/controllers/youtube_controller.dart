// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/youtube/presentation/controllers/youtube_controller.dart
// ARVIND PARTY - YOUTUBE ROOM CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../../models/youtube_video_model.dart';
import '../repositories/youtube_repository.dart';

class YouTubeController extends GetxController {
  final YouTubeRepository _repo = YouTubeRepository();

  // ─── Video State ───────────────────────────────────────────
  final currentVideo = Rxn<YouTubeVideo>();
  final playlist = <YouTubeVideo>[].obs;
  final isLoading = false.obs;
  final isPlaying = false.obs;
  final currentPosition = 0.0.obs;
  final videoDuration = 0.0.obs;
  final volume = 0.8.obs;

  // ─── Room State ────────────────────────────────────────────
  final String? roomId;
  final String? hostId;
  final String? currentUserId;
  final bool isHost;

  // ─── Watch Party ──────────────────────────────────────────
  final synchronizedPlayback = false.obs;
  final participants = <String>[].obs;
  final isConnected = false.obs;
  
  // Socket listener references for cleanup
  final Map<String, Function> _socketListeners = {};

  YouTubeController({
    this.roomId,
    this.hostId,
    this.currentUserId,
    this.isHost = false,
  });

  @override
  void onInit() {
    super.onInit();
    setupSocketListeners();
    loadPlaylist();
    if (roomId != null && currentUserId != null) {
      _repo.emitJoinRoom(roomId!, currentUserId!);
    }
  }

  @override
  void onClose() {
    // Remove all socket listeners before leaving
    _repo.removePlaybackSyncListener();
    _repo.removePlaylistUpdateListener();
    _repo.removeParticipantUpdateListener();
    _repo.removeVideoChangeListener();
    _repo.removeWatchPartyToggleListener();
    if (roomId != null && currentUserId != null) {
      _repo.emitLeaveRoom(roomId!, currentUserId!);
    }
    super.onClose();
  }

  // ══════════════════════════════════════════════════════════════
  // VIDEO MANAGEMENT
  // ══════════════════════════════════════════════════════════════

  Future<void> loadPlaylist() async {
    isLoading.value = true;
    try {
      playlist.assignAll(await _repo.getPlaylist());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchVideos(String query) async {
    isLoading.value = true;
    try {
      final results = await _repo.searchVideos(query);
      playlist.assignAll(results);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> playVideo(YouTubeVideo video) async {
    currentVideo.value = video;
    isPlaying.value = true;
    currentPosition.value = 0.0;
    videoDuration.value = video.duration ?? 0.0;
    if (roomId != null) {
      _repo.emitChangeVideo(roomId!, video.id);
    }
  }

  void togglePlayPause() {
    if (roomId == null) return;
    if (!isHost) return;
    isPlaying.value = !isPlaying.value;
    _repo.emitTogglePlayPause(roomId!, isPlaying.value);
  }

  void seekTo(double position) {
    if (roomId == null) return;
    if (!isHost) return;
    currentPosition.value = position;
    _repo.emitSeekTo(roomId!, position);
  }

  Future<void> addToPlaylist(YouTubeVideo video) async {
    if (!isHost) return;
    await _repo.addToPlaylist(video);
    playlist.add(video);
  }

  Future<void> removeFromPlaylist(int index) async {
    if (!isHost) return;
    final video = playlist[index];
    await _repo.removeFromPlaylist(video.id);
    playlist.removeAt(index);
  }

  void playNext() {
    if (currentVideo.value == null) return;
    final currentIndex = playlist.indexWhere((v) => v.id == currentVideo.value!.id);
    if (currentIndex < playlist.length - 1) {
      playVideo(playlist[currentIndex + 1]);
    }
  }

  void playPrevious() {
    if (currentVideo.value == null) return;
    final currentIndex = playlist.indexWhere((v) => v.id == currentVideo.value!.id);
    if (currentIndex > 0) {
      playVideo(playlist[currentIndex - 1]);
    }
  }

  // ══════════════════════════════════════════════════════════════
  // WATCH PARTY
  // ══════════════════════════════════════════════════════════════

  void toggleWatchParty() {
    if (hostId != currentUserId && !isHost) return;
    synchronizedPlayback.value = !synchronizedPlayback.value;
    if (roomId != null) {
      _repo.emitToggleWatchParty(roomId!, synchronizedPlayback.value);
    }
  }

  void joinWatchParty(String userId) {
    if (!participants.contains(userId)) {
      participants.add(userId);
    }
  }

  void leaveWatchParty(String userId) {
    participants.remove(userId);
  }

  // ══════════════════════════════════════════════════════════════
  // SOCKET LISTENERS
  // ══════════════════════════════════════════════════════════════

  void setupSocketListeners() {
    _repo.listenToPlaybackSync((data) {
      final isPlaying = data['isPlaying'] as bool? ?? false;
      final position = (data['position'] as num?)?.toDouble() ?? 0.0;
      this.isPlaying.value = isPlaying;
      currentPosition.value = position;
    });

    _repo.listenToPlaylistUpdate((videos) {
      playlist.assignAll(
        videos.map((v) => YouTubeVideo.fromJson(Map<String, dynamic>.from(v as Map))).toList(),
      );
    });

    _repo.listenToParticipantUpdate((users) {
      participants.assignAll(
        users.map((u) => u.toString()).toList(),
      );
    });

    _repo.listenToVideoChange((data) {
      final videoDto = Map<String, dynamic>.from(data);
      currentVideo.value = YouTubeVideo.fromJson(videoDto);
      isPlaying.value = true;
      currentPosition.value = 0.0;
    });
    
    _repo.listenToWatchPartyToggle((data) {
      final enabled = data['enabled'] as bool? ?? false;
      synchronizedPlayback.value = enabled;
    });
  }
}
