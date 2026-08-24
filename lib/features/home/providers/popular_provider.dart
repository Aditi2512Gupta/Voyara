// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../../core/providers/location_provider.dart';
// import 'home_provider.dart';
// import '../data/models/destination_model.dart';
// import '../data/models/location_model.dart';
// import '../data/repositories/popular_repository.dart';
// import 'home_data_provider.dart';

// final popularRepositoryProvider = Provider<PopularRepository>(
//   (ref) => PopularRepository(ref.read(geoapifyRepositoryProvider)),
// );

// final popularCountryProvider = FutureProvider<LocationModel>((ref) async {
//   final position = await ref.watch(currentLocationProvider.future);
//   return ref.read(geoapifyRepositoryProvider).reverseGeocode(
//         lat: position.latitude,
//         lon: position.longitude,
//       );
// });

// final popularDestinationsProvider =
//     FutureProvider<List<DestinationModel>>((ref) async {
//   final homeData = await ref.watch(homeDataProvider.future);
//   return homeData.popular;
// });

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/location_provider.dart';
import '../data/models/destination_model.dart';
import '../data/models/location_model.dart';
import 'home_provider.dart';
import 'home_data_provider.dart';

final popularCountryProvider = FutureProvider<LocationModel>((ref) async {
  final position = await ref.watch(currentLocationProvider.future);

  return ref.read(geoapifyRepositoryProvider).reverseGeocode(
        lat: position.latitude,
        lon: position.longitude,
      );
});

final popularDestinationsProvider =
    FutureProvider<List<DestinationModel>>((ref) async {
  final homeData = await ref.watch(homeDataProvider.future);

  return homeData.popular;
});