import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/travel_interest_model.dart';
import '../data/repositories/travel_interest_repository.dart';
import '../data/services/travel_interest_service.dart';

final travelInterestServiceProvider =
    Provider((ref) => TravelInterestService());

final travelInterestRepositoryProvider =
    Provider(
      (ref) => TravelInterestRepository(
        service: ref.read(travelInterestServiceProvider),
      ),
    );

final travelInterestsProvider =
    FutureProvider<List<TravelInterestModel>>((ref) {
      return ref
          .read(travelInterestRepositoryProvider)
          .getInterests();
    });