import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../media/domain/entities/media_item.dart';

enum WatchStatus { watching, completed, planned, dropped }

extension WatchStatusLabel on WatchStatus {
  String get label {
    return switch (this) {
      WatchStatus.watching => 'Watching',
      WatchStatus.completed => 'Completed',
      WatchStatus.planned => 'Planned',
      WatchStatus.dropped => 'Dropped',
    };
  }
}

class WatchlistController extends ChangeNotifier {
  WatchlistController() {
    ready = _hydrate();
  }

  final Map<int, MediaItem> _items = {};
  final Map<int, WatchStatus> _statuses = {};
  final Set<int> _favorites = {};
  late final Future<void> ready;
  SharedPreferences? _prefs;

  List<MediaItem> get items => List.unmodifiable(_items.values);

  bool contains(MediaItem item) {
    return _items.containsKey(item.id);
  }

  bool isFavorite(MediaItem item) {
    return _favorites.contains(item.id);
  }

  WatchStatus statusFor(MediaItem item) {
    return _statuses[item.id] ?? WatchStatus.planned;
  }

  Future<void> _hydrate() async {
    _prefs = await SharedPreferences.getInstance();
    final rawItems = _prefs!.getString('watchlist_items');
    final rawStatuses = _prefs!.getString('watchlist_statuses');

    if (rawItems != null) {
      final decoded = jsonDecode(rawItems) as List<dynamic>;
      for (final entry in decoded) {
        final map = entry as Map<String, dynamic>;
        final item = MediaItem(
          id: map['id'] as int? ?? 0,
          title: map['title'] as String? ?? 'Untitled',
          overview: map['overview'] as String? ?? '',
          mediaType: MediaType.values.firstWhere(
            (type) => type.name == map['mediaType'],
            orElse: () => MediaType.unknown,
          ),
          posterPath: map['posterPath'] as String?,
          backdropPath: map['backdropPath'] as String?,
          releaseDate: map['releaseDate'] as String?,
          voteAverage: (map['voteAverage'] as num?)?.toDouble() ?? 0,
        );
        _items[item.id] = item;
      }
    }

    if (rawStatuses != null) {
      final decoded = jsonDecode(rawStatuses) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        final status = WatchStatus.values.firstWhere(
          (value) => value.name == entry.value,
          orElse: () => WatchStatus.planned,
        );
        _statuses[int.parse(entry.key)] = status;
      }
    }

    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    await prefs.setString(
      'watchlist_items',
      jsonEncode(
        _items.values.map((item) => {
          'id': item.id,
          'title': item.title,
          'overview': item.overview,
          'mediaType': item.mediaType.name,
          'posterPath': item.posterPath,
          'backdropPath': item.backdropPath,
          'releaseDate': item.releaseDate,
          'voteAverage': item.voteAverage,
        }).toList(),
      ),
    );
    await prefs.setString(
      'watchlist_statuses',
      jsonEncode(
        _statuses.map((key, value) => MapEntry(key.toString(), value.name)),
      ),
    );
  }

  Future<void> toggle(MediaItem item, {WatchStatus status = WatchStatus.planned}) async {
    if (contains(item)) {
      _items.remove(item.id);
      _statuses.remove(item.id);
      _favorites.remove(item.id);
    } else {
      _items[item.id] = item;
      _statuses[item.id] = status;
    }
    notifyListeners();
    await _persist();
  }

  Future<void> add(MediaItem item, {WatchStatus status = WatchStatus.planned}) async {
    _items[item.id] = item;
    _statuses[item.id] = status;
    notifyListeners();
    await _persist();
  }

  Future<void> move(MediaItem item, WatchStatus status) async {
    _items[item.id] = item;
    _statuses[item.id] = status;
    notifyListeners();
    await _persist();
  }

  Future<void> markWatched(MediaItem item) async {
    await move(item, WatchStatus.completed);
  }

  Future<void> toggleFavorite(MediaItem item) async {
    _items[item.id] = item;
    if (_favorites.contains(item.id)) {
      _favorites.remove(item.id);
    } else {
      _favorites.add(item.id);
    }
    _statuses.putIfAbsent(item.id, () => WatchStatus.planned);
    notifyListeners();
    await _persist();
  }

  List<MediaItem> byStatus(WatchStatus status) {
    return _items.values
        .where((item) => (_statuses[item.id] ?? WatchStatus.planned) == status)
        .toList();
  }

  int get movieCount {
    return items.where((item) => item.mediaType == MediaType.movie).length;
  }

  int get seriesCount {
    return items.where((item) => item.mediaType == MediaType.tv).length;
  }

  int get favoriteCount => _favorites.length;

  double get averageRating {
    if (items.isEmpty) {
      return 0;
    }
    final total = items.fold<double>(
      0,
      (sum, item) => sum + item.voteAverage,
    );
    return total / items.length;
  }

  int get completedCount => byStatus(WatchStatus.completed).length;

  double get completionPercentage {
    if (items.isEmpty) {
      return 0;
    }
    return completedCount / items.length;
  }

  int get estimatedHoursWatched {
    return completedCount * 2;
  }

  String get favoriteGenre {
    if (items.isEmpty) {
      return 'Action';
    }
    if (seriesCount > movieCount) {
      return 'Drama';
    }
    return 'Cinema';
  }
}
