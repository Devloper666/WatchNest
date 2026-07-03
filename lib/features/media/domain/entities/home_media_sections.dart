import 'media_item.dart';

class HomeMediaSections {
  const HomeMediaSections({
    required this.continueWatching,
    required this.trendingToday,
    required this.popularMovies,
    required this.popularTvShows,
    required this.topRated,
    required this.upcoming,
    required this.recommended,
  });

  final List<MediaItem> continueWatching;
  final List<MediaItem> trendingToday;
  final List<MediaItem> popularMovies;
  final List<MediaItem> popularTvShows;
  final List<MediaItem> topRated;
  final List<MediaItem> upcoming;
  final List<MediaItem> recommended;
}
