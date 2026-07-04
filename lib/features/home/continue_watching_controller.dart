import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../media/domain/entities/media_item.dart';

class ContinueWatchingController extends ChangeNotifier {
  ContinueWatchingController() {
    ready = _hydrate();
  }

  final Map<int, MediaItem> _items = {};
  final Map<int, double> _progress = {};
  late final Future<void> ready;
  SharedPreferences? _prefs;

  List<MediaItem> get items => List.unmodifiable(_items.values);

  double progressFor(MediaItem item) => _progress[item.id] ?? 0;

  bool contains(MediaItem item) => _items.containsKey(item.id);

  Future<void> _hydrate() async {
    _prefs = await SharedPreferences.getInstance();
    final rawItems = _prefs!.getString('continue_watching_items');
    final rawProgress = _prefs!.getString('continue_watching_progress');

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

    if (rawProgress != null) {
      final decoded = jsonDecode(rawProgress) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        _progress[int.parse(entry.key)] = (entry.value as num).toDouble();
      }
    }

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
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    await prefs.setString(
      'continue_watching_items',
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
      'continue_watching_progress',
      jsonEncode(_progress.map((key, value) => MapEntry(key.toString(), value))),
    );
  }
}
