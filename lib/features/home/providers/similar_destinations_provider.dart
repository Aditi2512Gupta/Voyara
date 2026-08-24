import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/destination_model.dart';
import 'discover_provider.dart';

final similarDestinationsProvider =
    FutureProvider.family<List<DestinationModel>, String>((
      ref,
      category,
    ) async {
      // Temporary: search by category name
      return ref.read(discoverSearchProvider(category).future);
    });
