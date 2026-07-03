class ApiConstants {
  static const tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const tmdbToken = String.fromEnvironment(
    'TMDB_TOKEN',
    defaultValue:
        'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI1OGVlNmViMDRjNDU3MzdkNzg4M2NmZTNlYjVjZDg4MiIsIm5iZiI6MTczMDYzODEwNS43NDUsInN1YiI6IjY3Mjc3MTE5Mjk3MzVkNmEwNGRhNjhmNCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.AkKRgeoDYWIcxP3lyRmu1uVt4T2Gb-1nhIZW1XzJVJ4',
  );
}
