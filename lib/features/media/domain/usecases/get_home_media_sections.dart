import '../entities/home_media_sections.dart';
import '../repositories/media_repository.dart';

class GetHomeMediaSections {
  const GetHomeMediaSections(this._repository);

  final MediaRepository _repository;

  Future<HomeMediaSections> call() async {
    final results = await Future.wait([
      _repository.getTrending(),
      _repository.getPopularMovies(),
      _repository.getPopularTvShows(),
      _repository.getTopRated(),
      _repository.getUpcoming(),
      _repository.getRecommended(),
    ]);

    final trendingToday = results[0];

    return HomeMediaSections(
      continueWatching: trendingToday.take(8).toList(),
      trendingToday: trendingToday,
      popularMovies: results[1],
      popularTvShows: results[2],
      topRated: results[3],
      upcoming: results[4],
      recommended: results[5],
    );
  }
}
