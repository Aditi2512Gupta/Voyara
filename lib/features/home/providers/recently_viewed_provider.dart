import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/destination_model.dart';

class RecentlyViewedNotifier
    extends StateNotifier<List<DestinationModel>> {
  RecentlyViewedNotifier() : super([]);

  void add(DestinationModel destination) {
    state = [
      destination,
      ...state.where((e) => e.id != destination.id),
    ];
  }
}

final recentlyViewedProvider =
    StateNotifierProvider<
        RecentlyViewedNotifier,
        List<DestinationModel>>(
  (ref) => RecentlyViewedNotifier(),
);