import '../entities/media_item.dart';
import '../entities/media_details.dart';

abstract class MediaRepository {
  Future<List<MediaItem>> getTrending();
  Future<List<MediaItem>> getPopularMovies();
  Future<List<MediaItem>> getPopularTvShows();
  Future<List<MediaItem>> getTopRated();
  Future<List<MediaItem>> getUpcoming();
  Future<List<MediaItem>> getRecommended();
  Future<MediaDetails> getDetails(MediaItem item);
  Future<List<MediaItem>> search(String query);
}
