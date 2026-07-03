import '../entities/media_details.dart';
import '../entities/media_item.dart';
import '../repositories/media_repository.dart';

class GetMediaDetails {
  const GetMediaDetails(this._repository);

  final MediaRepository _repository;

  Future<MediaDetails> call(MediaItem item) {
    return _repository.getDetails(item);
  }
}
