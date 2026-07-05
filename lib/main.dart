import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'app/watchnest_app.dart';
import 'core/network/dio_client.dart';
import 'features/auth/data/datasources/firebase_auth_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/register_with_email_and_password.dart';
import 'features/auth/domain/usecases/send_password_reset_email.dart';
import 'features/auth/domain/usecases/sign_in_with_email_and_password.dart';
import 'features/auth/domain/usecases/sign_in_with_google.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/home/continue_watching_controller.dart';
import 'features/home/home_controller.dart';
import 'features/media/data/datasources/tmdb_remote_data_source.dart';
import 'features/media/data/repositories/media_repository_impl.dart';
import 'features/media/domain/repositories/media_repository.dart';
import 'features/media/domain/usecases/get_home_media_sections.dart';
import 'features/media/domain/usecases/search_media.dart';
import 'features/search/media_search_controller.dart';
import 'features/watchlist/watchlist_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

  final dioClient = DioClient();
  final remoteDataSource = TmdbRemoteDataSource(dioClient.dio);
  final MediaRepository mediaRepository = MediaRepositoryImpl(remoteDataSource);
  final FirebaseAuthDataSource firebaseAuthDataSource = FirebaseAuthDataSource();
  final AuthRepository authRepository = AuthRepositoryImpl(firebaseAuthDataSource);

  runApp(
    MultiProvider(
      providers: [
        Provider<MediaRepository>.value(value: mediaRepository),
        Provider<AuthRepository>.value(value: authRepository),
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
        ChangeNotifierProvider(
          create: (_) => AuthController(
            repository: authRepository,
            signInWithEmailAndPassword: SignInWithEmailAndPassword(authRepository),
            registerWithEmailAndPassword: RegisterWithEmailAndPassword(authRepository),
            signInWithGoogle: SignInWithGoogle(authRepository),
            sendPasswordResetEmail: SendPasswordResetEmail(authRepository),
          ),
        ),
      ],
      child: const WatchNestApp(),
    ),
  );
}
