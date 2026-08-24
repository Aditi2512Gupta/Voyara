import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/recent_search_model.dart';

class RecentSearchNotifier
    extends StateNotifier<List<RecentSearchModel>> {
  RecentSearchNotifier() : super([]);

  void addSearch(String query) {
    final text = query.trim();

    if (text.isEmpty) return;

    state = [
      RecentSearchModel(query: text),

      ...state.where(
        (item) =>
            item.query.toLowerCase() !=
            text.toLowerCase(),
      ),
    ];

    if (state.length > 8) {
      state = state.sublist(0, 8);
    }
  }

  void clear() {
    state = [];
  }
}

final recentSearchProvider = StateNotifierProvider<
    RecentSearchNotifier,
    List<RecentSearchModel>>(
  (ref) => RecentSearchNotifier(),
);