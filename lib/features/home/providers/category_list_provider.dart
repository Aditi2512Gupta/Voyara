import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_data_provider.dart';
import 'home_provider.dart';

final categoryListProvider = FutureProvider<List<String>>((ref) async {
  final homeData = await ref.watch(homeDataProvider.future);

  return ref
      .read(categoryRepositoryProvider)
      .categoriesFromDestinations(homeData.destinations);
});