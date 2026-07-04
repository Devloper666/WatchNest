import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/media/domain/entities/media_item.dart';

class MediaPersistenceService {
  const MediaPersistenceService(this._prefs);

  final SharedPreferences _prefs;

  static Future<MediaPersistenceService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return MediaPersistenceService(prefs);
  }

  List<MediaItem> readMediaItems(String key) {
    final rawItems = _prefs.getString(key);
    if (rawItems == null || rawItems.isEmpty) {
      return <MediaItem>[];
    }

    final decoded = jsonDecode(rawItems) as List<dynamic>;
    return decoded.whereType<Map<String, dynamic>>().map(_decodeMediaItem).toList();
  }

  Future<void> saveMediaItems(String key, Iterable<MediaItem> items) async {
    final payload = items.map(_encodeMediaItem).toList();
    await _prefs.setString(key, jsonEncode(payload));
  }

  Map<int, String> readStringMap(String key) {
    final rawValues = _prefs.getString(key);
    if (rawValues == null || rawValues.isEmpty) {
      return <int, String>{};
    }

    final decoded = jsonDecode(rawValues) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(int.parse(key), value.toString()));
  }

  Future<void> saveStringMap(String key, Map<int, String> values) async {
    final payload = values.map((key, value) => MapEntry(key.toString(), value));
    await _prefs.setString(key, jsonEncode(payload));
  }

  Map<int, double> readDoubleMap(String key) {
    final rawValues = _prefs.getString(key);
    if (rawValues == null || rawValues.isEmpty) {
      return <int, double>{};
    }

    final decoded = jsonDecode(rawValues) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(int.parse(key), (value as num).toDouble()));
  }

  Future<void> saveDoubleMap(String key, Map<int, double> values) async {
    final payload = values.map((key, value) => MapEntry(key.toString(), value));
    await _prefs.setString(key, jsonEncode(payload));
  }

  Set<int> readIntSet(String key) {
    final rawValues = _prefs.getString(key);
    if (rawValues == null || rawValues.isEmpty) {
      return <int>{};
    }

    final decoded = jsonDecode(rawValues) as List<dynamic>;
    return decoded.whereType<num>().map((value) => value.toInt()).toSet();
  }

  Future<void> saveIntSet(String key, Iterable<int> values) async {
    final payload = values.toSet().toList();
    await _prefs.setString(key, jsonEncode(payload));
  }

  static Map<String, dynamic> _encodeMediaItem(MediaItem item) {
    return {
      'id': item.id,
      'title': item.title,
      'overview': item.overview,
      'mediaType': item.mediaType.name,
      'posterPath': item.posterPath,
      'backdropPath': item.backdropPath,
      'releaseDate': item.releaseDate,
      'voteAverage': item.voteAverage,
      'genres': item.genres,
      'runtimeMinutes': item.runtimeMinutes,
    };
  }

  static MediaItem _decodeMediaItem(Map<String, dynamic> map) {
    return MediaItem(
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
      genres: (map['genres'] as List<dynamic>?)?.whereType<String>().toList() ?? const <String>[],
      runtimeMinutes: (map['runtimeMinutes'] as num?)?.toInt() ?? 0,
    );
  }
}
