import '../../../../core/constants/api.dart';
import '../../domain/entities/media_item.dart';

class MediaItemModel extends MediaItem {
  const MediaItemModel({
    required super.id,
    required super.title,
    required super.overview,
    required super.mediaType,
    super.posterPath,
    super.backdropPath,
    super.releaseDate,
    super.voteAverage,
  });

  factory MediaItemModel.fromJson(
    Map<String, dynamic> json, {
    MediaType fallbackType = MediaType.unknown,
  }) {
    final mediaType = _mediaTypeFromString(
      json['media_type'] as String?,
      fallbackType,
    );
    final title = json['title'] ?? json['name'] ?? json['original_name'];
    final posterPath = json['poster_path'] ?? json['profile_path'];

    return MediaItemModel(
      id: json['id'] as int? ?? 0,
      title: title as String? ?? 'Untitled',
      overview: json['overview'] as String? ?? '',
      mediaType: mediaType,
      posterPath: _fullImagePath(posterPath as String?),
      backdropPath: _fullImagePath(json['backdrop_path'] as String?),
      releaseDate: json['release_date'] ?? json['first_air_date'],
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
    );
  }

  static MediaType _mediaTypeFromString(String? type, MediaType fallbackType) {
    return switch (type) {
      'movie' => MediaType.movie,
      'tv' => MediaType.tv,
      'person' => MediaType.person,
      _ => fallbackType,
    };
  }

  static String? _fullImagePath(String? path) {
    if (path == null || path.isEmpty) {
      return null;
    }
    return '${ApiConstants.tmdbImageBaseUrl}$path';
  }
}
