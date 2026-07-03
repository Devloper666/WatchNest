import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/media/domain/entities/media_item.dart';
import '../../features/watchlist/watchlist_controller.dart';
import 'media_navigation.dart';

class MediaListTile extends StatelessWidget {
  const MediaListTile({
    required this.item,
    super.key,
  });

  static const _radius = 22.0;

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(_radius),
      onTap: () => openMediaDetails(context, item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_radius),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  SizedBox(
                    width: 86,
                    height: 124,
                    child: Hero(
                      tag: item.heroTag,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _PosterImage(item: item),
                            const _MiniPosterGradient(),
                            Positioned(
                              left: 8,
                              bottom: 8,
                              child: _RatingBadge(rating: item.voteAverage),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    height: 1.12,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${item.voteAverage.toStringAsFixed(1)}  •  ${item.year}  •  ${item.typeLabel}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        if (item.overview.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            item.overview,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      height: 1.35,
                                    ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Consumer<WatchlistController>(
                    builder: (context, watchlist, _) {
                      final isSaved = watchlist.contains(item);
                      return IconButton.filledTonal(
                        tooltip: isSaved
                            ? 'Remove from watchlist'
                            : 'Add to watchlist',
                        onPressed: () => watchlist.toggle(item),
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isSaved
                                ? Icons.check_rounded
                                : Icons.bookmark_border,
                            key: ValueKey(isSaved),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PosterImage extends StatelessWidget {
  const _PosterImage({required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (item.posterPath == null) {
      return ColoredBox(
        color: colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.image_not_supported_outlined, size: 26),
      );
    }

    return CachedNetworkImage(
      imageUrl: item.posterPath!,
      fit: BoxFit.cover,
      placeholder: (_, _) => const ColoredBox(color: Color(0xFF20242D)),
      errorWidget: (_, _, _) => ColoredBox(
        color: colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.image_not_supported_outlined, size: 26),
      ),
    );
  }
}

class _MiniPosterGradient extends StatelessWidget {
  const _MiniPosterGradient();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.72),
          ],
        ),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.64),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, size: 13, color: Color(0xFFFFD166)),
            const SizedBox(width: 2),
            Text(
              rating.toStringAsFixed(1),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
