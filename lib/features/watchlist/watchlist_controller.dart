import 'package:flutter/foundation.dart';

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
  final Map<int, MediaItem> _items = {};
  final Map<int, WatchStatus> _statuses = {};
  final Set<int> _favorites = {};

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

  void toggle(MediaItem item, {WatchStatus status = WatchStatus.planned}) {
    if (contains(item)) {
      _items.remove(item.id);
      _statuses.remove(item.id);
      _favorites.remove(item.id);
    } else {
      _items[item.id] = item;
      _statuses[item.id] = status;
    }
    notifyListeners();
  }

  void add(MediaItem item, {WatchStatus status = WatchStatus.planned}) {
    _items[item.id] = item;
    _statuses[item.id] = status;
    notifyListeners();
  }

  void move(MediaItem item, WatchStatus status) {
    _items[item.id] = item;
    _statuses[item.id] = status;
    notifyListeners();
  }

  void markWatched(MediaItem item) {
    move(item, WatchStatus.completed);
  }

  void toggleFavorite(MediaItem item) {
    _items[item.id] = item;
    if (_favorites.contains(item.id)) {
      _favorites.remove(item.id);
    } else {
      _favorites.add(item.id);
    }
    _statuses.putIfAbsent(item.id, () => WatchStatus.planned);
    notifyListeners();
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
