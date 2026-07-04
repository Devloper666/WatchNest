import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/widgets/animated_watchlist_button.dart';
import '../../shared/widgets/media_poster_card.dart';
import '../../shared/widgets/section_header.dart';
import '../media/domain/entities/media_details.dart';
import '../media/domain/entities/media_item.dart';
import '../media/domain/repositories/media_repository.dart';
import '../media/domain/usecases/get_media_details.dart';
import '../watchlist/watchlist_controller.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({required this.item, super.key});

  final MediaItem item;

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late final Future<MediaDetails> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = GetMediaDetails(
      context.read<MediaRepository>(),
    )(widget.item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton.filled(
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withValues(alpha: 0.42),
          ),
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: FutureBuilder<MediaDetails>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          final details = snapshot.data;
          final item = details?.item ?? widget.item;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              _HeroHeader(item: item),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 260),
                  opacity: snapshot.connectionState == ConnectionState.waiting
                      ? 0.65
                      : 1,
                  child: details == null
                      ? const Padding(
                          padding: EdgeInsets.only(top: 24),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : _DetailsBody(details: details),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    final backdrop = item.backdropPath ?? item.posterPath;

    return SizedBox(
      height: MediaQuery.sizeOf(context).height.clamp(560, 760) * 0.58,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (backdrop != null)
            CachedNetworkImage(imageUrl: backdrop, fit: BoxFit.cover)
          else
            ColoredBox(color: Theme.of(context).colorScheme.surfaceContainer),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.10),
                  Colors.black.withValues(alpha: 0.50),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 18,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 132,
                  child: Hero(
                    tag: item.heroTag,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: AspectRatio(
                        aspectRatio: 2 / 3,
                        child: item.posterPath == null
                            ? ColoredBox(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                ),
                              )
                            : CachedNetworkImage(
                                imageUrl: item.posterPath!,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              height: 1.04,
                            ),
                      ),
                      const SizedBox(height: 10),
                      _MetaWrap(item: item, runtime: null),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsBody extends StatelessWidget {
  const _DetailsBody({required this.details});

  final MediaDetails details;

  @override
  Widget build(BuildContext context) {
    final item = details.item;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ActionRow(details: details),
        const SizedBox(height: 18),
        _MetaWrap(item: item, runtime: details.runtimeLabel),
        const SizedBox(height: 14),
        if (details.genres.isNotEmpty) _GenreWrap(genres: details.genres),
        const SizedBox(height: 18),
        Text(
          item.overview.isEmpty ? 'No overview available yet.' : item.overview,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.55,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 24),
        if (details.item.mediaType == MediaType.tv) ...[
          _InfoLine(label: 'Status', value: details.status.isEmpty ? 'TBA' : details.status),
          _InfoLine(
            label: 'Seasons',
            value: details.seasons > 0 ? details.seasons.toString() : 'TBA',
          ),
          _InfoLine(
            label: 'Episodes',
            value: details.episodesCount > 0 ? details.episodesCount.toString() : 'TBA',
          ),
          _InfoLine(
            label: 'First air date',
            value: details.firstAirDate ?? 'TBA',
          ),
          _InfoLine(
            label: 'Last air date',
            value: details.lastAirDate ?? 'TBA',
          ),
          _InfoLine(
            label: 'Networks',
            value: details.networks.isEmpty ? 'TBA' : details.networks.join(', '),
          ),
          _InfoLine(
            label: 'Creators',
            value: details.creators.isEmpty ? 'TBA' : details.creators.join(', '),
          ),
        ] else ...[
          _InfoLine(label: 'Release date', value: item.releaseDate ?? 'TBA'),
          _InfoLine(label: 'Runtime', value: details.runtimeLabel),
        ],
        _InfoLine(label: 'Cast', value: details.cast.join(', ')),
        _InfoLine(label: 'Director', value: details.director),
        _InfoLine(
          label: 'Writers',
          value: details.writers.isEmpty ? 'TBA' : details.writers.join(', '),
        ),
        if (details.productionCompanies.isNotEmpty)
          _InfoLine(
            label: 'Production',
            value: details.productionCompanies.join(', '),
          ),
        if (details.externalLinks.isNotEmpty)
          _InfoLine(label: 'Links', value: details.externalLinks.join(', ')),
        const SizedBox(height: 24),
        if (details.videos.isNotEmpty) ...[
          const SectionHeader(title: 'Videos'),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: details.videos.map((video) {
              return OutlinedButton.icon(
                onPressed: () => launchUrl(Uri.parse(video.watchUrl)),
                icon: const Icon(Icons.play_circle_outline),
                label: Text(video.name),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 24),
        if (details.similar.isNotEmpty) ...[
          const SectionHeader(title: 'Similar Titles'),
          const SizedBox(height: 14),
          SizedBox(
            height: 230,
            child: ListView.separated(
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              itemCount: details.similar.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                return MediaPosterCard(
                  item: details.similar[index],
                  width: 148,
                );
              },
            ),
          ),
        ],
        if (details.recommendations.isNotEmpty) ...[
          const SizedBox(height: 24),
          const SectionHeader(title: 'Recommended for You'),
          const SizedBox(height: 14),
          SizedBox(
            height: 230,
            child: ListView.separated(
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              itemCount: details.recommendations.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                return MediaPosterCard(
                  item: details.recommendations[index],
                  width: 148,
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.details});

  final MediaDetails details;

  @override
  Widget build(BuildContext context) {
    final item = details.item;
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<WatchlistController>(
      builder: (context, watchlist, _) {
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              onPressed: () => watchlist.add(item),
              icon: AnimatedWatchlistButton(item: item, size: 32),
              label: const Text('Watchlist'),
            ),
            FilledButton.tonalIcon(
              onPressed: () => watchlist.markWatched(item),
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('Watched'),
            ),
            FilledButton.tonalIcon(
              onPressed: () => watchlist.toggleFavorite(item),
              icon: Icon(
                watchlist.isFavorite(item)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: watchlist.isFavorite(item) ? colorScheme.primary : null,
              ),
              label: const Text('Favorite'),
            ),
            FilledButton.tonalIcon(
              onPressed: details.trailerKey == null
                  ? null
                  : () => Clipboard.setData(
                        ClipboardData(
                          text:
                              'https://www.youtube.com/watch?v=${details.trailerKey}',
                        ),
                      ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Trailer'),
            ),
            FilledButton.tonalIcon(
              onPressed: () => Clipboard.setData(
                ClipboardData(text: 'Watch ${item.title} on WatchNest'),
              ),
              icon: const Icon(Icons.ios_share_outlined),
              label: const Text('Share'),
            ),
          ],
        );
      },
    );
  }
}

class _MetaWrap extends StatelessWidget {
  const _MetaWrap({required this.item, required this.runtime});

  final MediaItem item;
  final String? runtime;

  @override
  Widget build(BuildContext context) {
    final values = [
      item.voteAverage.toStringAsFixed(1),
      item.year,
      item.typeLabel,
      ?runtime,
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values
          .map(
            (value) => _Pill(
              icon: value == values.first ? Icons.star_rounded : null,
              label: value,
            ),
          )
          .toList(),
    );
  }
}

class _GenreWrap extends StatelessWidget {
  const _GenreWrap({required this.genres});

  final List<String> genres;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: genres.map((genre) => _Pill(label: genre)).toList(),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: const Color(0xFFFFD166)),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
