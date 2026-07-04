import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/media_list_tile.dart';
import 'media_search_controller.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _textController = TextEditingController();
  final _debouncer = _Debouncer(const Duration(milliseconds: 360));

  @override
  void dispose() {
    _debouncer.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              textInputAction: TextInputAction.search,
              onSubmitted: context.read<MediaSearchController>().search,
              onChanged: (value) {
                _debouncer.run(
                  () => context.read<MediaSearchController>().search(value),
                );
              },
              decoration: InputDecoration(
                hintText: 'Search movies and series',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Search',
                  onPressed: () {
                    context
                        .read<MediaSearchController>()
                        .search(_textController.text);
                  },
                  icon: const Icon(Icons.arrow_forward),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Consumer<MediaSearchController>(
              builder: (context, controller, _) {
                return Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SegmentedButton<SearchFilter>(
                        segments: const [
                          ButtonSegment(
                            value: SearchFilter.all,
                            label: Text('All'),
                          ),
                          ButtonSegment(
                            value: SearchFilter.movies,
                            label: Text('Movies'),
                          ),
                          ButtonSegment(
                            value: SearchFilter.tvShows,
                            label: Text('TV Shows'),
                          ),
                        ],
                        selected: {controller.filter},
                        onSelectionChanged: (value) {
                          controller.setFilter(value.first);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<SearchSort>(
                      initialValue: controller.sort,
                      decoration: const InputDecoration(
                        labelText: 'Sort by',
                        prefixIcon: Icon(Icons.sort_rounded),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: SearchSort.popular,
                          child: Text('Popular'),
                        ),
                        DropdownMenuItem(
                          value: SearchSort.rating,
                          child: Text('Rating'),
                        ),
                        DropdownMenuItem(
                          value: SearchSort.newest,
                          child: Text('Newest'),
                        ),
                        DropdownMenuItem(
                          value: SearchSort.oldest,
                          child: Text('Oldest'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          controller.setSort(value);
                        }
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<MediaSearchController>(
                builder: (context, controller, _) {
                  if (controller.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.errorMessage != null) {
                    return EmptyState(
                      title: 'Search paused',
                      message: controller.errorMessage!,
                      icon: Icons.search_off,
                    );
                  }

                  if (controller.results.isEmpty) {
                    return const EmptyState(
                      title: 'Find your next title',
                      message: 'Search TMDB for movies and series.',
                      icon: Icons.search,
                    );
                  }

                  return ListView.builder(
                    itemCount: controller.results.length,
                    itemBuilder: (context, index) {
                      return MediaListTile(item: controller.results[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Debouncer {
  _Debouncer(this.delay);

  final Duration delay;
  VoidCallback? _callback;
  Future<void>? _pending;

  void run(VoidCallback callback) {
    _callback = callback;
    _pending ??= Future<void>.delayed(delay).then((_) {
      final callback = _callback;
      _callback = null;
      _pending = null;
      callback?.call();
    });
  }

  void dispose() {
    _callback = null;
  }
}
