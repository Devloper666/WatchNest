class MediaVideo {
  const MediaVideo({
    required this.name,
    required this.key,
    required this.type,
    this.site = 'YouTube',
  });

  final String name;
  final String key;
  final String type;
  final String site;

  String get watchUrl => 'https://www.youtube.com/watch?v=$key';

  bool get isYouTube => site.toLowerCase() == 'youtube';
}
