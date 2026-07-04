import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/watchnest_app.dart';
import 'core/network/dio_client.dart';
import 'features/home/continue_watching_controller.dart';
import 'features/home/home_controller.dart';
import 'features/media/data/datasources/tmdb_remote_data_source.dart';
import 'features/media/data/repositories/media_repository_impl.dart';
import 'features/media/domain/repositories/media_repository.dart';
import 'features/media/domain/usecases/get_home_media_sections.dart';
import 'features/media/domain/usecases/search_media.dart';
import 'features/search/media_search_controller.dart';
import 'features/watchlist/watchlist_controller.dart';

void main() {
  final dioClient = DioClient();
  final remoteDataSource = TmdbRemoteDataSource(dioClient.dio);
  final MediaRepository mediaRepository = MediaRepositoryImpl(remoteDataSource);

  runApp(
    MultiProvider(
      providers: [
        Provider<MediaRepository>.value(value: mediaRepository),
        ChangeNotifierProvider(
          create: (_) => WatchlistController(),
        ),
        ChangeNotifierProvider(
          create: (_) => ContinueWatchingController(),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeController(
            getHomeMediaSections: GetHomeMediaSections(mediaRepository),
          )..loadHome(),
        ),
        ChangeNotifierProvider(
          create: (_) => MediaSearchController(
            searchMedia: SearchMedia(mediaRepository),
          ),
        ),
      ],
      child: const WatchNestApp(),
    ),
  );
}
