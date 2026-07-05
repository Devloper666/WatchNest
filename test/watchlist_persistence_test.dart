import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:watchnest/features/media/domain/entities/media_item.dart';
import 'package:watchnest/features/watchlist/watchlist_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads persisted watchlist entries on startup', () async {
    SharedPreferences.setMockInitialValues({
      'watchlist_items': jsonEncode([
        {
          'id': 1,
          'title': 'Inception',
          'overview': 'Dreams',
          'mediaType': 'movie',
          'voteAverage': 8.8,
          'releaseDate': '2010-07-16',
        }
      ]),
      'watchlist_statuses': jsonEncode({'1': 'watching'}),
    });

    final controller = WatchlistController();
    await controller.ready;

    expect(controller.items, hasLength(1));
    expect(controller.contains(const MediaItem(
      id: 1,
      title: 'Inception',
      overview: 'Dreams',
      mediaType: MediaType.movie,
      releaseDate: '2010-07-16',
      voteAverage: 8.8,
    )), isTrue);
    expect(
      controller.statusFor(const MediaItem(
        id: 1,
        title: 'Inception',
        overview: 'Dreams',
        mediaType: MediaType.movie,
        releaseDate: '2010-07-16',
        voteAverage: 8.8,
      )),
      WatchStatus.watching,
    );
  });

  test('restores persisted favorites alongside the watchlist', () async {
    SharedPreferences.setMockInitialValues({
      'watchlist_items': jsonEncode([
        {
          'id': 2,
          'title': 'Interstellar',
          'overview': 'Space',
          'mediaType': 'movie',
          'voteAverage': 8.6,
          'releaseDate': '2014-11-07',
        }
      ]),
      'watchlist_statuses': jsonEncode({'2': 'planned'}),
      'watchlist_favorites': jsonEncode([2]),
    });

    final controller = WatchlistController();
    await controller.ready;

    final item = const MediaItem(
      id: 2,
      title: 'Interstellar',
      overview: 'Space',
      mediaType: MediaType.movie,
      releaseDate: '2014-11-07',
      voteAverage: 8.6,
    );

    expect(controller.items, hasLength(1));
    expect(controller.isFavorite(item), isTrue);
    expect(controller.favoriteCount, 1);
  });
}
