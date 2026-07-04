import 'media_item.dart';
import 'media_video.dart';

class MediaDetails {
  const MediaDetails({
    required this.item,
    required this.runtimeMinutes,
    required this.genres,
    required this.cast,
    required this.director,
    required this.similar,
    required this.recommendations,
    required this.productionCompanies,
    required this.externalLinks,
    required this.videos,
    required this.creators,
    required this.writers,
    required this.seasons,
    required this.episodesCount,
    required this.status,
    required this.firstAirDate,
    required this.lastAirDate,
    required this.networks,
    this.trailerKey,
  });

  final MediaItem item;
  final int runtimeMinutes;
  final List<String> genres;
  final List<String> cast;
  final String director;
  final List<MediaItem> similar;
  final List<MediaItem> recommendations;
  final List<String> productionCompanies;
  final List<String> externalLinks;
  final List<MediaVideo> videos;
  final List<String> creators;
  final List<String> writers;
  final int seasons;
  final int episodesCount;
  final String status;
  final String? firstAirDate;
  final String? lastAirDate;
  final List<String> networks;
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

  bool get hasTvDetails => item.mediaType == MediaType.tv;
}
