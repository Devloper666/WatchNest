import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/media/domain/entities/media_item.dart';
import '../../features/watchlist/watchlist_controller.dart';

class AnimatedWatchlistButton extends StatelessWidget {
  const AnimatedWatchlistButton({
    required this.item,
    this.size = 38,
    this.status = WatchStatus.planned,
    super.key,
  });

  final MediaItem item;
  final double size;
  final WatchStatus status;

  @override
  Widget build(BuildContext context) {
    return Consumer<WatchlistController>(
      builder: (context, watchlist, _) {
        final isSaved = watchlist.contains(item);
        return IconButton.filled(
          visualDensity: VisualDensity.compact,
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withValues(alpha: 0.56),
            foregroundColor: Colors.white,
            fixedSize: Size(size, size),
          ),
          tooltip: isSaved ? 'Remove from watchlist' : 'Add to watchlist',
          onPressed: () => watchlist.toggle(item, status: status),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutBack,
                ),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Icon(
              isSaved ? Icons.check_rounded : Icons.add_rounded,
              key: ValueKey(isSaved),
              size: size * 0.52,
            ),
          ),
        );
      },
    );
  }
}
