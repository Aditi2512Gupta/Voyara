import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/recent_search_provider.dart';
import '../../providers/search_provider.dart';

class SearchBarWidget extends ConsumerWidget {
  const SearchBarWidget({super.key, required this.controller});

  final SearchController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SearchBar(
      controller: controller,
      hintText: "Search destinations...",
      leading: const Icon(Icons.search),

      onTap: () {
        context.push('/search');
      },

      onChanged: (value) {
        if (value.trim().isEmpty) return;
        ref.read(searchQueryProvider.notifier).state = value;
      },

      onSubmitted: (query) {
        ref.read(searchQueryProvider.notifier).state = query;
        ref.read(recentSearchProvider.notifier).addSearch(query);
        context.push('/search');
      },

      elevation: const WidgetStatePropertyAll(0),
      backgroundColor: WidgetStatePropertyAll(Colors.grey.shade200),
    );
  }
}
