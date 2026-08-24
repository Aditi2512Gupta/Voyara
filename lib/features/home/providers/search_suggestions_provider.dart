import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/destination_model.dart';
import 'discover_provider.dart';

final destinationSuggestionsProvider =
    FutureProvider.family<List<DestinationModel>, String>((ref, query) async {
  if (query.trim().isEmpty) {
    return [];
  }

  return ref.read(discoverSearchProvider(query).future);
});