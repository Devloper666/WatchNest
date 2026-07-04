import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../features/media/domain/entities/media_item.dart';
import 'animated_watchlist_button.dart';
import 'media_navigation.dart';

class MediaPosterCard extends StatelessWidget {
  const MediaPosterCard({
    required this.item,
    this.compact = false,
    this.width,
    super.key,
  });

  static const _radius = 22.0;

  final MediaItem item;
  final bool compact;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final fallbackWidth = width ?? (compact ? 136.0 : 164.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedWidth =
            constraints.hasBoundedWidth && constraints.maxWidth.isFinite;

        return _PressableCard(
          onTap: () => openMediaDetails(context, item),
          child: SizedBox(
            width: hasBoundedWidth ? null : fallbackWidth,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_radius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.34),
                    blurRadius: 26,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: Hero(
                  tag: item.heroTag,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(_radius),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _PosterImage(item: item),
                        const _PosterGradient(),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: _RatingBadge(rating: item.voteAverage),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: AnimatedWatchlistButton(item: item),
                        ),
                        Positioned(
                          left: 14,
                          right: 14,
                          bottom: 14,
                          child: _PosterDetails(item: item),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
        child: const Icon(Icons.image_not_supported_outlined, size: 32),
      );
    }

    return CachedNetworkImage(
      imageUrl: item.posterPath!,
      fit: BoxFit.cover,
      placeholder: (_, _) => const ColoredBox(color: Color(0xFF20242D)),
      errorWidget: (_, _, _) => ColoredBox(
        color: colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.image_not_supported_outlined, size: 32),
      ),
    );
  }
}

class _PosterGradient extends StatelessWidget {
  const _PosterGradient();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.12),
            Colors.black.withValues(alpha: 0.02),
            Colors.black.withValues(alpha: 0.72),
            Colors.black.withValues(alpha: 0.96),
          ],
          stops: const [0, 0.36, 0.68, 1],
        ),
      ),
    );
  }
}

class _PosterDetails extends StatelessWidget {
  const _PosterDetails({required this.item});

  final MediaItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                height: 1.12,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.65),
                    blurRadius: 10,
                  ),
                ],
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Flexible(
              child: Text(
                '${item.voteAverage.toStringAsFixed(1)}  •  ${item.year}  •  ${item.typeLabel}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ],
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
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFD166)),
            const SizedBox(width: 3),
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

class _PressableCard extends StatefulWidget {
  const _PressableCard({
    required this.child,
    required this.onTap,
  });

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
