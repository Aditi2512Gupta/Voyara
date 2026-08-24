import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/destination_model.dart';
import 'selected_category_provider.dart';
import 'home_data_provider.dart';

final categoryDestinationsProvider = Provider<List<DestinationModel>>((ref) {
  final selected = ref.watch(selectedCategoryProvider);

  final homeData = ref.watch(homeDataProvider);

  return homeData.maybeWhen(
    data: (data) {
      if (selected == null) {
        return data.destinations;
      }

      return data.destinations.where((destination) {
        return destination.categories.contains(selected);
      }).toList();
    },
    orElse: () => [],
  );
});
