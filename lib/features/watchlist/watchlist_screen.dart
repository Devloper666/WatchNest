import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/media_list_tile.dart';
import 'watchlist_controller.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Watchlist')),
      body: Consumer<WatchlistController>(
        builder: (context, controller, _) {
          if (controller.items.isEmpty) {
            return const EmptyState(
              title: 'Your watchlist is empty',
              message: 'Add titles from Home or Search to keep them here.',
              icon: Icons.bookmark_border,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: controller.items.length,
            itemBuilder: (context, index) {
              return MediaListTile(item: controller.items[index]);
            },
          );
        },
      ),
    );
  }
}
