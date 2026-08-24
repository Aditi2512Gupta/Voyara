import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/discover_provider.dart';
import '../../providers/search_provider.dart';
import '../widgets/search_destination_card.dart';
import '../../providers/recent_search_provider.dart';

class SearchResultsPage extends ConsumerStatefulWidget {
  const SearchResultsPage({super.key});

  @override
  ConsumerState<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends ConsumerState<SearchResultsPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(searchQueryProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    ref.read(searchQueryProvider.notifier).state = value;
    if (value.trim().isEmpty) {
      if (context.mounted && GoRouter.of(context).canPop()) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);

    // Keep controller text synced with provider state
    if (_controller.text != query) {
      _controller.text = query;
    }

    final recentSearches = ref.watch(recentSearchProvider);
    final results = query.trim().isEmpty
        ? null
        : ref.watch(discoverSearchProvider(query));

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: _controller,
            autofocus: query.isEmpty,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: "Search destinations...",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        _onQueryChanged("");
                      },
                    )
                  : null,
              border: InputBorder.none,
            ),
            onChanged: _onQueryChanged,
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                ref.read(recentSearchProvider.notifier).addSearch(value);
              }
            },
          ),
        ),
      ),
      body: results == null
          ? (recentSearches.isEmpty
              ? const Center(child: Text("Start typing to search destinations"))
              : ListView.builder(
                  itemCount: recentSearches.length,
                  itemBuilder: (_, index) {
                    return ListTile(
                      leading: const Icon(Icons.history),
                      title: Text(recentSearches[index].query),
                      onTap: () {
                        ref.read(searchQueryProvider.notifier).state =
                            recentSearches[index].query;
                      },
                    );
                  },
                ))
          : results.when(
              data: (places) {
                if (places.isEmpty) {
                  return const Center(child: Text("No destinations found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: places.length,
                  itemBuilder: (_, index) {
                    final destination = places[index];

                    return SearchDestinationCard(
                      destination: destination,
                      onTap: () {
                        ref.read(recentSearchProvider.notifier).addSearch(query);
                        context.push('/destination', extra: destination);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
            ),
    );
  }
}
