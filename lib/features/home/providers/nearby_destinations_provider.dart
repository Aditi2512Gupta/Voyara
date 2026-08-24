import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/nearby_result_model.dart';
import 'home_data_provider.dart';

final nearbyDestinationsProvider = FutureProvider<NearbyResultModel>((
  ref,
) async {
  final homeData = await ref.watch(homeDataProvider.future);

  return NearbyResultModel(
    destinations: homeData.nearby,
    usedRadius: homeData.nearbyRadius * 1000,
  );
});
