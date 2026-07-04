import 'package:flutter/foundation.dart';

import '../../core/persistence/media_persistence.dart';
import '../media/domain/entities/media_item.dart';

class ContinueWatchingController extends ChangeNotifier {
  ContinueWatchingController() {
    ready = _hydrate();
  }

  final Map<int, MediaItem> _items = {};
  final Map<int, double> _progress = {};
  late final Future<void> ready;
  MediaPersistenceService? _persistence;

  List<MediaItem> get items => List.unmodifiable(_items.values);

  double progressFor(MediaItem item) => _progress[item.id] ?? 0;

  bool contains(MediaItem item) => _items.containsKey(item.id);

  Future<void> _hydrate() async {
    _persistence = await MediaPersistenceService.create();
    final savedItems = _persistence!.readMediaItems('continue_watching_items');
    for (final item in savedItems) {
      _items[item.id] = item;
    }

    final savedProgress = _persistence!.readDoubleMap('continue_watching_progress');
    _progress.addAll(savedProgress);

    notifyListeners();
  }

  Future<void> saveProgress(MediaItem item, double progress) async {
    if (item.id == 0) {
      return;
    }
    _items[item.id] = item;
    _progress[item.id] = progress.clamp(0, 1);
    notifyListeners();
    await _persist();
  }

  Future<void> markCompleted(MediaItem item) async {
    await saveProgress(item, 1.0);
  }

  Future<void> clear(MediaItem item) async {
    _items.remove(item.id);
    _progress.remove(item.id);
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final persistence = _persistence ?? await MediaPersistenceService.create();
    _persistence = persistence;
    await persistence.saveMediaItems('continue_watching_items', _items.values);
    await persistence.saveDoubleMap('continue_watching_progress', _progress);
  }
}
