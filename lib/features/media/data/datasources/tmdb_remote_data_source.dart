import 'package:dio/dio.dart';

import '../../domain/entities/media_details.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/entities/media_video.dart';
import '../models/media_item_model.dart';

class TmdbRemoteDataSource {
  const TmdbRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<MediaItemModel>> getTrending() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/trending/all/day',
      queryParameters: const {'language': 'en-US'},
    );
    return _readResults(response.data);
  }

  Future<List<MediaItemModel>> getPopularMovies() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/movie/popular',
      queryParameters: const {'language': 'en-US', 'page': 1},
    );
    return _readResults(response.data, fallbackType: MediaType.movie);
  }

  Future<List<MediaItemModel>> getPopularTvShows() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/tv/popular',
      queryParameters: const {'language': 'en-US', 'page': 1},
    );
    return _readResults(response.data, fallbackType: MediaType.tv);
  }

  Future<List<MediaItemModel>> getTopRated() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/movie/top_rated',
      queryParameters: const {'language': 'en-US', 'page': 1},
    );
    return _readResults(response.data, fallbackType: MediaType.movie);
  }

  Future<List<MediaItemModel>> getUpcoming() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/movie/upcoming',
      queryParameters: const {'language': 'en-US', 'page': 1},
    );
    return _readResults(response.data, fallbackType: MediaType.movie);
  }

  Future<List<MediaItemModel>> getRecommended() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/discover/movie',
      queryParameters: const {
        'include_adult': false,
        'include_video': false,
        'language': 'en-US',
        'page': 1,
        'sort_by': 'vote_average.desc',
        'vote_count.gte': 500,
      },
    );
    return _readResults(response.data, fallbackType: MediaType.movie);
  }

  Future<List<MediaItemModel>> search(String query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/search/multi',
      queryParameters: {
        'query': query,
        'include_adult': false,
        'language': 'en-US',
        'page': 1,
      },
    );
    return _readResults(response.data);
  }

  Future<MediaDetails> getDetails(MediaItem item) async {
    final mediaPath = item.mediaType == MediaType.tv ? 'tv' : 'movie';
    final response = await _dio.get<Map<String, dynamic>>(
      '/$mediaPath/${item.id}',
      queryParameters: const {
        'language': 'en-US',
        'append_to_response': 'credits,videos,similar',
      },
    );
    final data = response.data ?? {};
    final fallbackType =
        item.mediaType == MediaType.tv ? MediaType.tv : MediaType.movie;
    final detailedItem = MediaItemModel.fromJson(
      {
        ...data,
        'media_type': fallbackType == MediaType.tv ? 'tv' : 'movie',
      },
      fallbackType: fallbackType,
    );

    final credits = data['credits'] as Map<String, dynamic>? ?? {};
    final crew = credits['crew'] as List<dynamic>? ?? [];
    final cast = credits['cast'] as List<dynamic>? ?? [];
    final videos = data['videos'] as Map<String, dynamic>? ?? {};
    final videoResults = videos['results'] as List<dynamic>? ?? [];
    final similar = data['similar'] as Map<String, dynamic>? ?? {};

    final productionCompanies = data['production_companies'] as List<dynamic>? ?? [];
    final externalIds = data['external_ids'] as Map<String, dynamic>? ?? {};
    final homepage = data['homepage'] as String?;
    final imdbId = externalIds['imdb_id'] as String?;
    final videosList = videoResults
        .whereType<Map<String, dynamic>>()
        .map((video) => MediaVideo(
              name: video['name'] as String? ?? 'Trailer',
              key: video['key'] as String? ?? '',
              type: video['type'] as String? ?? 'Trailer',
              site: video['site'] as String? ?? 'YouTube',
            ))
        .where((video) => video.key.isNotEmpty)
        .take(8)
        .toList();

    return MediaDetails(
      item: detailedItem,
      runtimeMinutes: _runtimeFromJson(data),
      genres: _genresFromJson(data),
      cast: cast
          .whereType<Map<String, dynamic>>()
          .map((person) => person['name'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .take(8)
          .toList(),
      director: _directorFromCrew(crew, fallbackType),
      similar: _readResults(similar, fallbackType: fallbackType).take(12).toList(),
      recommendations: _readResults(
        data['recommendations'] as Map<String, dynamic>? ?? {},
        fallbackType: fallbackType,
      ).take(12).toList(),
      productionCompanies: productionCompanies
          .whereType<Map<String, dynamic>>()
          .map((company) => company['name'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .take(6)
          .toList(),
      externalLinks: [
        if (homepage != null && homepage.isNotEmpty) homepage,
        if (imdbId != null && imdbId.isNotEmpty) 'IMDb: $imdbId',
      ],
      videos: videosList,
      creators: _peopleFromJson(data['created_by']),
      writers: _peopleFromJson(data['credits']?['crew'] as List<dynamic>? ?? [],
          jobFilter: 'Writer'),
      seasons: (data['number_of_seasons'] as num?)?.toInt() ?? 0,
      episodesCount: (data['number_of_episodes'] as num?)?.toInt() ?? 0,
      status: data['status'] as String? ?? 'Unknown',
      firstAirDate: data['first_air_date'] as String?,
      lastAirDate: data['last_air_date'] as String?,
      networks: _networksFromJson(data['networks']),
      trailerKey: _trailerKey(videoResults),
    );
  }

  List<MediaItemModel> _readResults(
    Map<String, dynamic>? data, {
    MediaType fallbackType = MediaType.unknown,
  }) {
    final results = data?['results'] as List<dynamic>? ?? [];
    return results
        .whereType<Map<String, dynamic>>()
        .map((json) => MediaItemModel.fromJson(json, fallbackType: fallbackType))
        .where((item) => item.mediaType != MediaType.person)
        .toList();
  }

  int _runtimeFromJson(Map<String, dynamic> json) {
    final runtime = json['runtime'] as int?;
    if (runtime != null) {
      return runtime;
    }
    final episodeRuntime = json['episode_run_time'] as List<dynamic>?;
    return episodeRuntime?.whereType<int>().firstOrNull ?? 0;
  }

  List<String> _genresFromJson(Map<String, dynamic> json) {
    final genres = json['genres'] as List<dynamic>? ?? [];
    return genres
        .whereType<Map<String, dynamic>>()
        .map((genre) => genre['name'] as String? ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  String _directorFromCrew(List<dynamic> crew, MediaType type) {
    final director = crew.whereType<Map<String, dynamic>>().firstWhere(
          (person) => person['job'] == 'Director',
          orElse: () => const {},
        );
    final name = director['name'] as String?;
    if (name != null && name.isNotEmpty) {
      return name;
    }
    final creator = crew.whereType<Map<String, dynamic>>().firstWhere(
          (person) => person['job'] == 'Creator' || person['job'] == 'Executive Producer',
          orElse: () => const {},
        );
    return creator['name'] as String? ?? (type == MediaType.tv ? 'Series team' : 'Director TBA');
  }

  List<String> _peopleFromJson(Object? source, {String? jobFilter}) {
    if (source is List<dynamic>) {
      return source.whereType<Map<String, dynamic>>().where((person) {
        if (jobFilter == null) {
          return true;
        }
        return person['job'] == jobFilter;
      }).map((person) => person['name'] as String? ?? '').where((name) => name.isNotEmpty).toList();
    }
    if (source is Map<String, dynamic>) {
      final creators = source['created_by'] as List<dynamic>? ?? [];
      return creators.whereType<Map<String, dynamic>>().map((person) => person['name'] as String? ?? '').where((name) => name.isNotEmpty).toList();
    }
    return [];
  }

  List<String> _networksFromJson(Object? source) {
    final networks = source as List<dynamic>? ?? [];
    return networks.whereType<Map<String, dynamic>>().map((network) => network['name'] as String? ?? '').where((name) => name.isNotEmpty).toList();
  }

  String? _trailerKey(List<dynamic> videos) {
    final trailer = videos.whereType<Map<String, dynamic>>().firstWhere(
          (video) =>
              video['site'] == 'YouTube' &&
              (video['type'] == 'Trailer' || video['type'] == 'Teaser'),
          orElse: () => const {},
        );
    final key = trailer['key'] as String?;
    return key?.isNotEmpty == true ? key : null;
  }
}
