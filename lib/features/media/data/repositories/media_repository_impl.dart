import '../../domain/entities/media_item.dart';
import '../../domain/entities/media_details.dart';
import '../../domain/repositories/media_repository.dart';
import '../datasources/tmdb_remote_data_source.dart';

class MediaRepositoryImpl implements MediaRepository {
  const MediaRepositoryImpl(this._remoteDataSource);

  final TmdbRemoteDataSource _remoteDataSource;

  @override
  Future<List<MediaItem>> getTrending() {
    return _remoteDataSource.getTrending();
  }

  @override
  Future<List<MediaItem>> getPopularMovies() {
    return _remoteDataSource.getPopularMovies();
  }

  @override
  Future<List<MediaItem>> getPopularTvShows() {
    return _remoteDataSource.getPopularTvShows();
  }

  @override
  Future<List<MediaItem>> getTopRated() {
    return _remoteDataSource.getTopRated();
  }

  @override
  Future<List<MediaItem>> getUpcoming() {
    return _remoteDataSource.getUpcoming();
  }

  @override
  Future<List<MediaItem>> getRecommended() {
    return _remoteDataSource.getRecommended();
  }

  @override
  Future<MediaDetails> getDetails(MediaItem item) {
    return _remoteDataSource.getDetails(item);
  }

  @override
  Future<List<MediaItem>> search(String query) {
    return _remoteDataSource.search(query);
  }
}
