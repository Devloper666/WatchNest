import '../entities/media_item.dart';
import '../repositories/media_repository.dart';

class GetTrendingMedia {
  const GetTrendingMedia(this._repository);

  final MediaRepository _repository;

  Future<List<MediaItem>> call() {
    return _repository.getTrending();
  }
}
