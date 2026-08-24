import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/trip_filter.dart';

final tripFilterProvider =
    StateProvider<TripFilter>((ref) {
  return TripFilter.all;
});