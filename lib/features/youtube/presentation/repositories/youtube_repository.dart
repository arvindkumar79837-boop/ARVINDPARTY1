// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/youtube/presentation/repositories/youtube_repository.dart
// ARVIND PARTY - YOUTUBE REPOSITORY
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/socket/socket_service.dart';
import '../../models/youtube_video_model.dart';

class YouTubeRepository {
  final ApiService _api = Get.find<ApiService>();
  final SocketService _socket = Get.find<SocketService>();

  Future<List<YouTubeVideo>> getPlaylist() async {
    try {
      final response = await _api.get('/api/youtube/playlist');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> videos = response.data['videos'] ?? response.data;
        return videos.map((v) => YouTubeVideo.fromJson(v)).toList();
      }
      throw Exception('Failed to load playlist');
    } catch (e) {
      Get.log('YouTubeRepository.getPlaylist error: $e');
      rethrow;
    }
  }

  Future<List<YouTubeVideo>> searchVideos(String query) async {
    try {
      final response = await _api.get('/api/youtube/search', query: {'q': query});
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> videos = response.data['videos'] ?? response.data;
        return videos.map((v) => YouTubeVideo.fromJson(v)).toList();
      }
      return [];
    } catch (e) {
      Get.log('YouTubeRepository.searchVideos error: $e');
      return [];
    }
  }

  Future<YouTubeVideo?> getVideoDetails(String videoId) async {
    try {
      final response = await _api.get('/api/youtube/video/$videoId');
      if (response.statusCode == 200 && response.data != null) {
        return YouTubeVideo.fromJson(response.data);
      }
      return null;
    } catch (e) {
      Get.log('YouTubeRepository.getVideoDetails error: $e');
      return null;
    }
  }

  Future<void> addToPlaylist(YouTubeVideo video) async {
    try {
      await _api.post('/api/youtube/playlist/add', body: video.toJson());
    } catch (e) {
      Get.log('YouTubeRepository.addToPlaylist error: $e');
      rethrow;
    }
  }

  Future<void> removeFromPlaylist(String videoId) async {
    try {
      await _api.delete('/api/youtube/playlist/$videoId', body: {'videoId': videoId});
    } catch (e) {
      Get.log('YouTubeRepository.removeFromPlaylist error: $e');
      rethrow;
    }
  }

  Future<void> updatePlaybackState({
    required bool isPlaying,
    required double position,
    required String videoId,
    required String roomId,
  }) async {
    try {
      await _api.post('/api/youtube/playback/update', body: {
        'isPlaying': isPlaying,
        'position': position,
        'videoId': videoId,
        'roomId': roomId,
      });
    } catch (e) {
      Get.log('YouTubeRepository.updatePlaybackState error: $e');
    }
  }

  void listenToPlaybackSync(Function(Map<String, dynamic>) onSyncUpdate) {
    _socket.on('youtube:sync_update', (data) {
      onSyncUpdate(data);
    });
  }

  void listenToPlaylistUpdate(Function(List<dynamic>) onPlaylistUpdate) {
    _socket.on('youtube:playlist_updated', (data) {
      final videos = data['videos'] as List<dynamic>? ?? [];
      onPlaylistUpdate(videos);
    });
  }

  void listenToParticipantUpdate(Function(List<dynamic>) onParticipantUpdate) {
    _socket.on('youtube:participants_updated', (data) {
      final participants = data['participants'] as List<dynamic>? ?? [];
      onParticipantUpdate(participants);
    });
  }

  void listenToVideoChange(Function(Map<String, dynamic>) onVideoChange) {
    _socket.on('youtube:video_changed', (data) {
      onVideoChange(data);
    });
  }

  void listenToWatchPartyToggle(Function(Map<String, dynamic>) onToggle) {
    _socket.on('youtube:watch_party_toggled', (data) {
      onToggle(data);
    });
  }

  void removePlaybackSyncListener() => _socket.off('youtube:sync_update');
  void removePlaylistUpdateListener() => _socket.off('youtube:playlist_updated');
  void removeParticipantUpdateListener() => _socket.off('youtube:participants_updated');
  void removeVideoChangeListener() => _socket.off('youtube:video_changed');
  void removeWatchPartyToggleListener() => _socket.off('youtube:watch_party_toggled');

  void emitJoinRoom(String roomId, String userId) {
    _socket.emit('youtube:join_room', {'roomId': roomId, 'userId': userId});
  }

  void emitLeaveRoom(String roomId, String userId) {
    _socket.emit('youtube:leave_room', {'roomId': roomId, 'userId': userId});
  }

  void emitTogglePlayPause(String roomId, bool isPlaying) {
    _socket.emit('youtube:toggle_play', {
      'roomId': roomId,
      'isPlaying': isPlaying,
    });
  }

  void emitSeekTo(String roomId, double position) {
    _socket.emit('youtube:seek', {
      'roomId': roomId,
      'position': position,
    });
  }

  void emitChangeVideo(String roomId, String videoId) {
    _socket.emit('youtube:change_video', {
      'roomId': roomId,
      'videoId': videoId,
    });
  }

  void emitToggleWatchParty(String roomId, bool enabled) {
    _socket.emit('youtube:toggle_watch_party', {
      'roomId': roomId,
      'enabled': enabled,
    });
  }
}