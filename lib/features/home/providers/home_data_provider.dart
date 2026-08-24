// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../../core/providers/location_provider.dart';
// import 'home_provider.dart';

// final homeDataProvider = FutureProvider((ref) async {
//   final position = await ref.watch(
//     currentLocationProvider.future,
//   );

//   return ref.read(homeRepositoryProvider).loadHomeData(
//         latitude: position.latitude,
//         longitude: position.longitude,
//       );
// });

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/location_provider.dart';
import 'home_provider.dart';

final homeDataProvider = FutureProvider((ref) async {
  final position = await ref.watch(
    currentLocationProvider.future,
  );

  return ref.read(homeRepositoryProvider).loadHomeData(
        latitude: position.latitude,
        longitude: position.longitude,
      );
});