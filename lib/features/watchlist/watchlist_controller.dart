import 'package:flutter/foundation.dart';

import '../../core/persistence/media_persistence.dart';
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
  MediaPersistenceService? _persistence;

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
    _persistence = await MediaPersistenceService.create();
    final savedItems = _persistence!.readMediaItems('watchlist_items');
    for (final item in savedItems) {
      _items[item.id] = item;
    }

    final savedStatuses = _persistence!.readStringMap('watchlist_statuses');
    for (final entry in savedStatuses.entries) {
      final status = WatchStatus.values.firstWhere(
        (value) => value.name == entry.value,
        orElse: () => WatchStatus.planned,
      );
      _statuses[entry.key] = status;
    }

    _favorites.addAll(_persistence!.readIntSet('watchlist_favorites'));

    notifyListeners();
  }

  Future<void> _persist() async {
    final persistence = _persistence ?? await MediaPersistenceService.create();
    _persistence = persistence;
    await persistence.saveMediaItems('watchlist_items', _items.values);
    await persistence.saveStringMap(
      'watchlist_statuses',
      _statuses.map((key, value) => MapEntry(key, value.name)),
    );
    await persistence.saveIntSet('watchlist_favorites', _favorites);
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

  int get watchingCount => byStatus(WatchStatus.watching).length;

  int get plannedCount => byStatus(WatchStatus.planned).length;

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

  int get estimatedWatchMinutes {
    return items.fold<int>(0, (sum, item) {
      final status = _statuses[item.id] ?? WatchStatus.planned;
      if (status == WatchStatus.completed) {
        return sum + (item.runtimeMinutes > 0 ? item.runtimeMinutes : _estimateRuntimeMinutes(item));
      }
      if (status == WatchStatus.watching) {
        return sum + ((item.runtimeMinutes > 0 ? item.runtimeMinutes : _estimateRuntimeMinutes(item)) ~/ 2);
      }
      return sum;
    });
  }

  String get estimatedWatchTimeLabel {
    final totalMinutes = estimatedWatchMinutes;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    }
    if (hours > 0) {
      return '${hours}h';
    }
    return '${minutes}m';
  }

  String get favoriteGenre {
    final favoriteItems = items.where((item) => _favorites.contains(item.id)).toList();
    if (favoriteItems.isEmpty) {
      return 'No favorites';
    }

    final genreCounts = <String, int>{};
    for (final item in favoriteItems) {
      for (final genre in item.genres) {
        if (genre.isEmpty) {
          continue;
        }
        genreCounts[genre] = (genreCounts[genre] ?? 0) + 1;
      }
    }

    if (genreCounts.isEmpty) {
      return favoriteItems.first.mediaType == MediaType.tv ? 'Drama' : 'Action';
    }

    return genreCounts.entries.reduce((best, entry) => entry.value > best.value ? entry : best).key;
  }

  int _estimateRuntimeMinutes(MediaItem item) {
    return item.mediaType == MediaType.tv ? 45 : 120;
  }
}
