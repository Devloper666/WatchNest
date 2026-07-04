import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_tracker/app/watchnest_app.dart';
import 'package:my_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:my_tracker/features/auth/domain/usecases/register_with_email_and_password.dart';
import 'package:my_tracker/features/auth/domain/usecases/send_password_reset_email.dart';
import 'package:my_tracker/features/auth/domain/usecases/sign_in_with_email_and_password.dart';
import 'package:my_tracker/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:my_tracker/features/auth/presentation/auth_controller.dart';
import 'package:my_tracker/features/home/continue_watching_controller.dart';
import 'package:my_tracker/features/home/home_controller.dart';
import 'package:my_tracker/features/media/domain/entities/media_details.dart';
import 'package:my_tracker/features/media/domain/entities/media_item.dart';
import 'package:my_tracker/features/media/domain/repositories/media_repository.dart';
import 'package:my_tracker/features/media/domain/usecases/get_home_media_sections.dart';
import 'package:my_tracker/features/media/domain/usecases/search_media.dart';
import 'package:my_tracker/features/search/media_search_controller.dart';
import 'package:my_tracker/features/watchlist/watchlist_controller.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('WatchNest shows bottom navigation', (tester) async {
    final repository = _FakeMediaRepository();
    final authRepository = _FakeAuthRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<MediaRepository>.value(value: repository),
          Provider<AuthRepository>.value(value: authRepository),
          ChangeNotifierProvider(create: (_) => WatchlistController()),
          ChangeNotifierProvider(create: (_) => ContinueWatchingController()),
          ChangeNotifierProvider(
            create: (_) => HomeController(
              getHomeMediaSections: GetHomeMediaSections(repository),
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => MediaSearchController(
              searchMedia: SearchMedia(repository),
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

    expect(find.text('WatchNest'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);
  });

  testWidgets('Home screen does not overflow across common widths', (
    tester,
  ) async {
    final repository = _FakeMediaRepository.withItems();
    final authRepository = _FakeAuthRepository();

    for (final size in const [
      Size(300, 640),
      Size(390, 844),
      Size(820, 1180),
    ]) {
      await tester.binding.setSurfaceSize(size);
      tester.view.devicePixelRatio = 1;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<MediaRepository>.value(value: repository),
            Provider<AuthRepository>.value(value: authRepository),
            ChangeNotifierProvider(create: (_) => WatchlistController()),
            ChangeNotifierProvider(create: (_) => ContinueWatchingController()),
            ChangeNotifierProvider(
              create: (_) => HomeController(
                getHomeMediaSections: GetHomeMediaSections(repository),
              )..loadHome(),
            ),
            ChangeNotifierProvider(
              create: (_) => MediaSearchController(
                searchMedia: SearchMedia(repository),
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

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    }

    addTearDown(() => tester.binding.setSurfaceSize(null));
  });
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Stream<String?> authStateChanges() => Stream.value('test-user');

  @override
  Future<void> registerWithEmailAndPassword({required String email, required String password}) async {}

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}

  @override
  Future<void> signInWithEmailAndPassword({required String email, required String password}) async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {}

  @override
  String? get currentUserEmail => 'test@example.com';

  @override
  String? get currentUserId => 'test-user';
}

class _FakeMediaRepository implements MediaRepository {
  _FakeMediaRepository({this.items = const []});

  factory _FakeMediaRepository.withItems() {
    return _FakeMediaRepository(
      items: List.generate(
        20,
        (index) => MediaItem(
          id: index,
          title: 'A Very Long WatchNest Title Number $index',
          overview: 'A test title used to prove the Home layout is flexible.',
          mediaType: index.isEven ? MediaType.movie : MediaType.tv,
          releaseDate: '2026-01-01',
          voteAverage: 7.5,
        ),
      ),
    );
  }

  final List<MediaItem> items;

  @override
  Future<List<MediaItem>> getTrending() async {
    return items;
  }

  @override
  Future<List<MediaItem>> getPopularMovies() async {
    return items;
  }

  @override
  Future<List<MediaItem>> getPopularTvShows() async {
    return items;
  }

  @override
  Future<List<MediaItem>> getTopRated() async {
    return items;
  }

  @override
  Future<List<MediaItem>> getUpcoming() async {
    return items;
  }

  @override
  Future<List<MediaItem>> getRecommended() async {
    return items;
  }

  @override
  Future<List<MediaItem>> search(String query) async {
    return const [];
  }

  @override
  Future<MediaDetails> getDetails(MediaItem item) async {
    return MediaDetails(
      item: item,
      runtimeMinutes: 120,
      genres: const ['Drama'],
      cast: const ['Actor'],
      director: 'Director',
      similar: const [],
      recommendations: const [],
      productionCompanies: const [],
      externalLinks: const [],
      videos: const [],
      creators: const [],
      writers: const [],
      seasons: 0,
      episodesCount: 0,
      status: 'Released',
      firstAirDate: null,
      lastAirDate: null,
      networks: const [],
      trailerKey: null,
    );
  }
}
