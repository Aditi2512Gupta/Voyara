import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/destination_model.dart';
import 'home_data_provider.dart';

final homeDestinationsProvider = Provider<List<DestinationModel>>((ref) {
  final homeData = ref.watch(homeDataProvider);

  return homeData.maybeWhen(
    data: (data) => data.destinations,
    orElse: () => [],
  );
});