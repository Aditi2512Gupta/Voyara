import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/location_provider.dart';
import '../data/models/location_model.dart';
import 'home_provider.dart';

final currentCityProvider = FutureProvider<LocationModel>((ref) async {
  final position = await ref.watch(currentLocationProvider.future);

  return ref.read(geoapifyRepositoryProvider).reverseGeocode(
        lat: position.latitude,
        lon: position.longitude,
      );
});