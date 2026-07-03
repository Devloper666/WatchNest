import 'package:flutter/foundation.dart';

import '../media/domain/entities/home_media_sections.dart';
import '../media/domain/entities/media_item.dart';
import '../media/domain/usecases/get_home_media_sections.dart';

class HomeController extends ChangeNotifier {
  HomeController({required this.getHomeMediaSections});

  final GetHomeMediaSections getHomeMediaSections;

  List<MediaItem> continueWatching = [];
  List<MediaItem> trendingToday = [];
  List<MediaItem> popularMovies = [];
  List<MediaItem> popularTvShows = [];
  List<MediaItem> topRated = [];
  List<MediaItem> upcoming = [];
  List<MediaItem> recommended = [];
  bool isLoading = false;
  String? errorMessage;

  bool get hasContent {
    return [
      continueWatching,
      trendingToday,
      popularMovies,
      popularTvShows,
      topRated,
      upcoming,
      recommended,
    ].any((section) => section.isNotEmpty);
  }

  Future<void> loadHome() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _setSections(await getHomeMediaSections());
    } catch (_) {
      errorMessage = 'Could not load home sections.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTrending() => loadHome();

  void _setSections(HomeMediaSections sections) {
    continueWatching = sections.continueWatching;
    trendingToday = sections.trendingToday;
    popularMovies = sections.popularMovies;
    popularTvShows = sections.popularTvShows;
    topRated = sections.topRated;
    upcoming = sections.upcoming;
    recommended = sections.recommended;
  }
}
