import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/media/domain/entities/media_item.dart';
import 'continue_watching_controller.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/media_poster_card.dart';
import '../../shared/widgets/section_header.dart';
import 'home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _pagePadding = 16.0;
  static const _sectionSpacing = 28.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('WatchNest'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: context.read<HomeController>().loadHome,
        child: Consumer<HomeController>(
          builder: (context, controller, _) {
            if (controller.isLoading && !controller.hasContent) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.errorMessage != null && !controller.hasContent) {
              return ListView(
                children: [
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.22),
                  EmptyState(
                    title: 'No signal from TMDB',
                    message: controller.errorMessage!,
                  ),
                ],
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final contentWidth =
                    constraints.maxWidth - (_pagePadding * 2);
                final cardWidth = (contentWidth * 0.42).clamp(132.0, 178.0);
                final railHeight = cardWidth * 1.5;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    _pagePadding,
                    96,
                    _pagePadding,
                    28,
                  ),
                  children: [
                    const _GreetingHeader(),
                    const SizedBox(height: 30),
                    Consumer<ContinueWatchingController>(
                      builder: (context, continueWatching, _) {
                        final items = continueWatching.items;
                        return items.isEmpty
                            ? const SizedBox.shrink()
                            : _MediaCarousel(
                                title: 'Continue Watching',
                                items: items,
                                cardWidth: cardWidth,
                                railHeight: railHeight,
                              );
                      },
                    ),
                    _MediaCarousel(
                      title: 'Trending Today',
                      items: controller.trendingToday,
                      cardWidth: cardWidth,
                      railHeight: railHeight,
                    ),
                    _MediaCarousel(
                      title: 'Popular Movies',
                      items: controller.popularMovies,
                      cardWidth: cardWidth,
                      railHeight: railHeight,
                    ),
                    _MediaCarousel(
                      title: 'Popular TV Shows',
                      items: controller.popularTvShows,
                      cardWidth: cardWidth,
                      railHeight: railHeight,
                    ),
                    _MediaCarousel(
                      title: 'Top Rated',
                      items: controller.topRated,
                      cardWidth: cardWidth,
                      railHeight: railHeight,
                    ),
                    _MediaCarousel(
                      title: 'Upcoming',
                      items: controller.upcoming,
                      cardWidth: cardWidth,
                      railHeight: railHeight,
                    ),
                    _MediaCarousel(
                      title: 'Recommended for You',
                      items: controller.recommended,
                      cardWidth: cardWidth,
                      railHeight: railHeight,
                      bottomSpacing: 0,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greetingFor(now),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Welcome back, Fadi',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                height: 1.05,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          _dateLabel(now),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  String _greetingFor(DateTime now) {
    if (now.hour < 12) {
      return 'Good Morning';
    }
    if (now.hour < 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }

  String _dateLabel(DateTime now) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}

class _MediaCarousel extends StatelessWidget {
  const _MediaCarousel({
    required this.title,
    required this.items,
    required this.cardWidth,
    required this.railHeight,
    this.bottomSpacing = HomeScreen._sectionSpacing,
  });

  final String title;
  final List<MediaItem> items;
  final double cardWidth;
  final double railHeight;
  final double bottomSpacing;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title),
          const SizedBox(height: 14),
          SizedBox(
            height: railHeight,
            child: ListView.separated(
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                return MediaPosterCard(
                  item: items[index],
                  width: cardWidth,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
