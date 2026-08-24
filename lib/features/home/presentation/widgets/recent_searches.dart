import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/recent_search_provider.dart';

class RecentSearches extends ConsumerWidget {
  const RecentSearches({
    super.key,
    required this.onTap,
  });

  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searches = ref.watch(recentSearchProvider);

    if (searches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: searches.map((search) {
        return ActionChip(
          label: Text(search.query),
          onPressed: () => onTap(search.query),
        );
      }).toList(),
    );
  }
}