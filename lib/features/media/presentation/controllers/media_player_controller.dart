// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/media/presentation/controllers/media_player_controller.dart
// ARVIND PARTY - MEDIA PLAYER CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/media_item.dart';

class MediaPlayerController extends GetxController {
  // Reactive state
  final currentMedia = Rxn<MediaItem>();
  final playlist = <MediaItem>[].obs;
  final isPlaying = false.obs;
  final currentPosition = const Duration(seconds: 30).obs;
  final totalDuration = const Duration(minutes: 3, seconds: 45).obs;
  final playbackMode = 'sequential'.obs;
  final volume = 0.8.obs;
  final isLoading = false.obs;
  final errorMessage = Rxn<String>();
  final searchQuery = ''.obs;
  final filteredPlaylist = <MediaItem>[].obs;
  final categoryFilter = 'all'.obs;
  final isShuffled = false.obs;
  final loopMode = PlayerLoopMode.off.obs;

  // Sound effects panel
  final soundEffects = <MediaItem>[].obs;
  final activeSoundEffect = Rxn<MediaItem>();
  final soundEffectVolume = 0.5.obs;

  // YouTube
  final youtubeUrl = Rxn<String>();
  final youtubeTitle = ''.obs;
  final isYouTubeMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPlaylist();
    loadSoundEffects();
  }

  void loadPlaylist() {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      playlist.value = [
        const MediaItem(
          id: 'track_001',
          title: 'Party Anthem',
          artist: 'Arvind Official',
          audioUrl: 'https://example.com/track1.mp3',
          duration: Duration(minutes: 3, seconds: 45),
          playCount: 15420,
        ),
        const MediaItem(
          id: 'track_002',
          title: 'Summer Vibes',
          artist: 'DJ Arvind',
          audioUrl: 'https://example.com/track2.mp3',
          duration: Duration(minutes: 4, seconds: 12),
          playCount: 23100,
        ),
        const MediaItem(
          id: 'track_003',
          title: 'Night Session',
          artist: 'Party Mix',
          audioUrl: 'https://example.com/track3.mp3',
          duration: Duration(minutes: 5, seconds: 30),
          playCount: 8700,
        ),
        const MediaItem(
          id: 'track_004',
          title: 'Chill Morning',
          artist: 'Ambient Sounds',
          audioUrl: 'https://example.com/track4.mp3',
          duration: Duration(minutes: 6, seconds: 15),
          category: 'ambient',
          playCount: 4200,
        ),
        const MediaItem(
          id: 'track_005',
          title: 'Beat Drop',
          artist: 'Electronic',
          audioUrl: 'https://example.com/track5.mp3',
          duration: Duration(minutes: 3, seconds: 22),
          playCount: 18900,
        ),
      ];
      if (playlist.isNotEmpty && currentMedia.value == null) {
        currentMedia.value = playlist.first;
        totalDuration.value = playlist.first.duration;
      }
    } catch (e) {
      errorMessage.value = 'Failed to load playlist: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void loadSoundEffects() {
    soundEffects.value = [
      const MediaItem(
        id: 'sfx_001',
        title: 'Applause',
        artist: 'System',
        audioUrl: 'https://example.com/applause.mp3',
        duration: Duration(seconds: 3),
        category: 'soundEffect',
        playCount: 120000,
      ),
      const MediaItem(
        id: 'sfx_002',
        title: 'Laugh Track',
        artist: 'System',
        audioUrl: 'https://example.com/laugh.mp3',
        duration: Duration(seconds: 2),
        category: 'soundEffect',
        playCount: 98000,
      ),
      const MediaItem(
        id: 'sfx_003',
        title: 'Air Horn',
        artist: 'System',
        audioUrl: 'https://example.com/airhorn.mp3',
        duration: Duration(seconds: 1),
        category: 'soundEffect',
        playCount: 204000,
      ),
      const MediaItem(
        id: 'sfx_004',
        title: 'Drum Roll',
        artist: 'System',
        audioUrl: 'https://example.com/drumroll.mp3',
        duration: Duration(seconds: 4),
        category: 'soundEffect',
        playCount: 56000,
      ),
      const MediaItem(
        id: 'sfx_005',
        title: 'Winning Sound',
        artist: 'System',
        audioUrl: 'https://example.com/win.mp3',
        duration: Duration(seconds: 3),
        category: 'soundEffect',
        playCount: 150000,
      ),
    ];
  }

  // ─── Playback Controls ─────────────────────────────────────────────────

  void play() {
    try {
      if (currentMedia.value == null) return;
      isPlaying.value = true;
    } catch (e) {
      errorMessage.value = 'Playback error: ${e.toString()}';
    }
  }

  void pause() {
    isPlaying.value = false;
  }

  void togglePlayPause() {
    if (isPlaying.value) {
      pause();
    } else {
      play();
    }
  }

  void seekTo(Duration position) {
    try {
      currentPosition.value = position;
    } catch (e) {
      errorMessage.value = 'Seek error: ${e.toString()}';
    }
  }

  void next() {
    try {
      if (playlist.isEmpty) return;
      final currentIndex = currentMedia.value != null
          ? playlist.indexWhere((m) => m.id == currentMedia.value!.id)
          : -1;
      final nextIndex = currentIndex >= 0 && currentIndex < playlist.length - 1
          ? currentIndex + 1
          : 0;
      currentMedia.value = playlist[nextIndex];
      currentPosition.value = Duration.zero;
      totalDuration.value = playlist[nextIndex].duration;
      play();
    } catch (e) {
      errorMessage.value = 'Next track error: ${e.toString()}';
    }
  }

  void previous() {
    try {
      if (playlist.isEmpty) return;
      final currentIndex = currentMedia.value != null
          ? playlist.indexWhere((m) => m.id == currentMedia.value!.id)
          : -1;
      final prevIndex = currentIndex > 0 ? currentIndex - 1 : playlist.length - 1;
      currentMedia.value = playlist[prevIndex];
      currentPosition.value = Duration.zero;
      totalDuration.value = playlist[prevIndex].duration;
      play();
    } catch (e) {
      errorMessage.value = 'Previous track error: ${e.toString()}';
    }
  }

  void selectMedia(MediaItem media) {
    try {
      currentMedia.value = media;
      currentPosition.value = Duration.zero;
      totalDuration.value = media.duration;
      play();
    } catch (e) {
      errorMessage.value = 'Media selection error: ${e.toString()}';
    }
  }

  void selectMediaById(String id) {
    try {
      final media = playlist.firstWhereOrNull((m) => m.id == id);
      if (media != null) selectMedia(media);
    } catch (e) {
      errorMessage.value = 'Media selection error: ${e.toString()}';
    }
  }

  void toggleShuffle() {
    isShuffled.value = !isShuffled.value;
    if (isShuffled.value) {
      playlist.shuffle();
      Get.snackbar(
        'Shuffle',
        'Playback shuffled',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF9800),
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    }
  }

  void cycleLoopMode() {
    const modes = PlayerLoopMode.values;
    final idx = (loopMode.value.index + 1) % modes.length;
    loopMode.value = modes[idx];
    Get.snackbar(
      'Loop Mode',
      loopMode.value == PlayerLoopMode.off
          ? 'No loop'
          : loopMode.value == PlayerLoopMode.all
              ? 'Loop all'
              : 'Loop one',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFFF9800),
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }

  void setVolume(double value) {
    volume.value = value.clamp(0.0, 1.0);
  }

  void setSoundEffectVolume(double value) {
    soundEffectVolume.value = value.clamp(0.0, 1.0);
  }

  // ─── Sound Effects ─────────────────────────────────────────────────────

  void triggerSoundEffect(String id) {
    try {
      final effect = soundEffects.firstWhereOrNull((s) => s.id == id);
      if (effect != null) {
        activeSoundEffect.value = effect;
        Get.snackbar(
          'Sound Effect',
          'Playing: ${effect.title}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.purple,
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
        );
      }
    } catch (e) {
      errorMessage.value = 'Sound effect error: ${e.toString()}';
    }
  }

  // ─── Search & Filter ──────────────────────────────────────────────────

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void setCategoryFilter(String category) {
    categoryFilter.value = category;
    _applyFilters();
  }

  void _applyFilters() {
    final items = <MediaItem>[...playlist];
    if (categoryFilter.value != 'all') {
      items.retainWhere((m) => m.category == categoryFilter.value);
    }
    if (searchQuery.value.isNotEmpty) {
      items.retainWhere((m) =>
          m.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          m.artist.toLowerCase().contains(searchQuery.value.toLowerCase()));
    }
    filteredPlaylist.value = items;
  }

  // ─── YouTube Mode ─────────────────────────────────────────────────────

  void setYouTubeUrl(String url) {
    try {
      youtubeUrl.value = url;
      isYouTubeMode.value = true;
      youtubeTitle.value = 'YouTube Stream';
      Get.snackbar(
        'YouTube',
        'Loading stream...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = 'YouTube URL error: ${e.toString()}';
    }
  }

  void exitYouTubeMode() {
    isYouTubeMode.value = false;
    youtubeUrl.value = null;
    youtubeTitle.value = '';
  }

  @override
  void onClose() {
    pause();
    super.onClose();
  }
}

enum PlayerLoopMode { off, all, one }