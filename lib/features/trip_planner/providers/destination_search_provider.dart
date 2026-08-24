import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/data/models/geoapify_place_model.dart';
import '../../home/providers/home_provider.dart';

final destinationSearchProvider =
    FutureProvider.family<List<GeoapifyPlaceModel>, String>((ref, query) async {
  if (query.trim().isEmpty) {
    return [];
  }

  return ref
      .read(geoapifyRepositoryProvider)
      .searchPlaces(query);
});