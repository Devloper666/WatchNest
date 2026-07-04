import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/widgets/section_header.dart';
import '../watchlist/watchlist_controller.dart';
import 'version_label.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: Consumer<WatchlistController>(
        builder: (context, watchlist, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              const SectionHeader(
                title: 'Library Snapshot',
                subtitle: 'Stats update as you build your watchlist',
              ),
              const SizedBox(height: 16),
              _StatTile(
                icon: Icons.bookmark_border,
                label: 'Saved titles',
                value: watchlist.items.length.toString(),
              ),
              _StatTile(
                icon: Icons.movie_outlined,
                label: 'Movies',
                value: watchlist.movieCount.toString(),
              ),
              _StatTile(
                icon: Icons.live_tv_outlined,
                label: 'Series',
                value: watchlist.seriesCount.toString(),
              ),
              _StatTile(
                icon: Icons.star_border,
                label: 'Average rating',
                value: watchlist.averageRating.toStringAsFixed(1),
              ),
              _StatTile(
                icon: Icons.favorite_border,
                label: 'Favorites',
                value: watchlist.favoriteCount.toString(),
              ),
              _StatTile(
                icon: Icons.check_circle_outline,
                label: 'Completed',
                value: watchlist.completedCount.toString(),
              ),
              _StatTile(
                icon: Icons.play_circle_outline,
                label: 'Watching',
                value: watchlist.watchingCount.toString(),
              ),
              _StatTile(
                icon: Icons.schedule_outlined,
                label: 'Planned',
                value: watchlist.plannedCount.toString(),
              ),
              _StatTile(
                icon: Icons.access_time_outlined,
                label: 'Watch time',
                value: watchlist.estimatedWatchTimeLabel,
              ),
              const SizedBox(height: 8),
              const SectionHeader(
                title: 'Quick Insights',
                subtitle: 'A snapshot of your library habits',
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.auto_awesome_outlined),
                  title: const Text('Favorite genre'),
                  trailing: Text(watchlist.favoriteGenre),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Version'),
                  trailing: const VersionLabel(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label),
        trailing: Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}
