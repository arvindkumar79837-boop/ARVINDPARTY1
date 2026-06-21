// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/media/domain/entities/media_item.dart
// ARVIND PARTY - MEDIA ITEM ENTITY
// ═══════════════════════════════════════════════════════════════════════════

class MediaItem {
  final String id;
  final String title;
  final String artist;
  final String? coverUrl;
  final String audioUrl;
  final Duration duration;
  final String category;
  final bool isPlaying;
  final int playCount;

  const MediaItem({
    required this.id,
    required this.title,
    required this.artist,
    this.coverUrl,
    required this.audioUrl,
    required this.duration,
    this.category = 'music',
    this.isPlaying = false,
    this.playCount = 0,
  });

  MediaItem copyWith({
    String? id,
    String? title,
    String? artist,
    String? coverUrl,
    String? audioUrl,
    Duration? duration,
    String? category,
    bool? isPlaying,
    int? playCount,
  }) {
    return MediaItem(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      coverUrl: coverUrl ?? this.coverUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      category: category ?? this.category,
      isPlaying: isPlaying ?? this.isPlaying,
      playCount: playCount ?? this.playCount,
    );
  }
}