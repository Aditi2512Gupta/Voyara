import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_data_provider.dart';
import 'home_provider.dart';

final categoriesProvider = Provider<List<String>>((ref) {
  final homeData = ref.watch(homeDataProvider);

  return homeData.maybeWhen(
    data: (data) {
      return ref
          .read(categoryRepositoryProvider)
          .categoriesFromDestinations(
            data.destinations,
          );
    },
    orElse: () => [],
  );
});