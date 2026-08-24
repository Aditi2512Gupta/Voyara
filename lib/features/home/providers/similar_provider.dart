import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/destination_model.dart';
import '../data/repositories/similar_repository.dart';
import 'home_provider.dart';

final similarRepositoryProvider = Provider<SimilarRepository>(
  (ref) => SimilarRepository(
    ref.read(geoapifyRepositoryProvider),
  ),
);

final similarDestinationsProvider =
    FutureProvider.family<List<DestinationModel>, DestinationModel>(
  (ref, destination) {
    return ref.read(similarRepositoryProvider).getSimilar(
          destination: destination,
        );
  },
);