import 'package:flutter/foundation.dart';

import '../media/domain/entities/media_item.dart';
import '../media/domain/usecases/search_media.dart';

enum SearchFilter { all, movies, tvShows }

enum SearchSort { popular, rating, newest, oldest }

class MediaSearchController extends ChangeNotifier {
  MediaSearchController({required this.searchMedia});

  final SearchMedia searchMedia;

  List<MediaItem> _results = [];
  bool isLoading = false;
  String? errorMessage;
  SearchFilter filter = SearchFilter.all;
  SearchSort sort = SearchSort.popular;

  List<MediaItem> get results {
    final filtered = _results.where((item) {
      return switch (filter) {
        SearchFilter.all => true,
        SearchFilter.movies => item.mediaType == MediaType.movie,
        SearchFilter.tvShows => item.mediaType == MediaType.tv,
      };
    }).toList();

    filtered.sort((a, b) {
      return switch (sort) {
        SearchSort.popular => b.voteAverage.compareTo(a.voteAverage),
        SearchSort.rating => b.voteAverage.compareTo(a.voteAverage),
        SearchSort.newest => b.year.compareTo(a.year),
        SearchSort.oldest => a.year.compareTo(b.year),
      };
    });
    return filtered;
  }

  Future<void> search(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      _results = [];
      errorMessage = null;
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _results = await searchMedia(trimmedQuery);
    } catch (_) {
      errorMessage = 'Search failed. Try another title.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(SearchFilter value) {
    filter = value;
    notifyListeners();
  }

  void setSort(SearchSort value) {
    sort = value;
    notifyListeners();
  }
}
