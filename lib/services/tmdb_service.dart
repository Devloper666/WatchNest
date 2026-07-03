import 'package:dio/dio.dart';

import '../core/network/dio_client.dart';
import '../features/media/data/datasources/tmdb_remote_data_source.dart';

class TMDBService {
  TMDBService({Dio? dio})
      : _remoteDataSource = TmdbRemoteDataSource(dio ?? DioClient().dio);

  final TmdbRemoteDataSource _remoteDataSource;

  Future<List<dynamic>> search(String query) async {
    return _remoteDataSource.search(query);
  }

  Future<List<dynamic>> trending() async {
    return _remoteDataSource.getTrending();
  }
}
