enum MediaType { movie, tv, person, unknown }

class MediaItem {
  const MediaItem({
    required this.id,
    required this.title,
    required this.overview,
    required this.mediaType,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    this.voteAverage = 0,
    this.genres = const [],
    this.runtimeMinutes = 0,
  });

  final int id;
  final String title;
  final String overview;
  final MediaType mediaType;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final double voteAverage;
  final List<String> genres;
  final int runtimeMinutes;

  String get heroTag => 'media-$id-${mediaType.name}';

  String get year {
    if (releaseDate == null || releaseDate!.length < 4) {
      return 'TBA';
    }
    return releaseDate!.substring(0, 4);
  }

  String get typeLabel {
    return switch (mediaType) {
      MediaType.movie => 'Movie',
      MediaType.tv => 'Series',
      MediaType.person => 'Person',
      MediaType.unknown => 'Title',
    };
  }
}
