class ApiConstants {
  static const tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  /// Supply a TMDB bearer token at build time using either:
  /// --dart-define=TMDB_TOKEN=your_token
  /// or --dart-define-from-file=env.json
  static const tmdbToken = String.fromEnvironment(
    'TMDB_TOKEN',
    defaultValue: '',
  );
}
