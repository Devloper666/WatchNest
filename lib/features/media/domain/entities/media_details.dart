import 'media_item.dart';

class MediaDetails {
  const MediaDetails({
    required this.item,
    required this.runtimeMinutes,
    required this.genres,
    required this.cast,
    required this.director,
    required this.similar,
    this.trailerKey,
  });

  final MediaItem item;
  final int runtimeMinutes;
  final List<String> genres;
  final List<String> cast;
  final String director;
  final List<MediaItem> similar;
  final String? trailerKey;

  String get runtimeLabel {
    if (runtimeMinutes <= 0) {
      return 'Runtime TBA';
    }
    final hours = runtimeMinutes ~/ 60;
    final minutes = runtimeMinutes % 60;
    if (hours == 0) {
      return '${minutes}m';
    }
    if (minutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${minutes}m';
  }
}
