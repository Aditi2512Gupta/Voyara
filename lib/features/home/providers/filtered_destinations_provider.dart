import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/destination_model.dart';
import 'selected_category_provider.dart';
import 'discover_provider.dart';
import 'search_provider.dart';

final filteredDestinationsProvider = Provider<List<DestinationModel>>((ref) {
  final search = ref.watch(searchQueryProvider).toLowerCase().trim();

  final category = ref.watch(selectedCategoryProvider);

  final discover = ref.watch(discoverDestinationsProvider);
  return discover.maybeWhen(
    data: (data) {
      return data.where((destination) {
        final matchesSearch =
            search.isEmpty ||
            destination.title.toLowerCase().contains(search) ||
            destination.location.toLowerCase().contains(search) ||
            destination.categories.any(
              (category) => category.toLowerCase().contains(search),
            );

        final matchesCategory =
            category == null || destination.categories.contains(category);

        return matchesSearch && matchesCategory;
      }).toList();
    },
    orElse: () => [],
  );
});
