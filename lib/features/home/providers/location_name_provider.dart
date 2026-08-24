import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/location_model.dart';
import 'home_provider.dart';

final locationNameProvider =
    FutureProvider.family<LocationModel, ({double lat, double lon})>(
  (ref, location) {
    return ref.read(geoapifyRepositoryProvider).reverseGeocode(
          lat: location.lat,
          lon: location.lon,
        );
  },
);