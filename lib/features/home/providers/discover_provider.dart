// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../../core/providers/location_provider.dart';
// import '../data/models/destination_model.dart';
// import '../data/repositories/discover_repository.dart';
// import 'home_provider.dart';
// import 'nearby_destinations_provider.dart';
// import 'popular_provider.dart';
// import '../data/models/location_model.dart';

// final discoverRepositoryProvider = Provider<DiscoverRepository>(
//   (ref) => DiscoverRepository(ref.read(geoapifyRepositoryProvider)),
// );

// final discoverDestinationsProvider = FutureProvider<List<DestinationModel>>((
//   ref,
// ) async {
//   final position = await ref.watch(currentLocationProvider.future);

//   final nearbyResult = ref.watch(nearbyDestinationsProvider).valueOrNull;
//   final excludedIds = nearbyResult?.destinations.map((e) => e.id).toSet() ?? <String>{};

//   return ref
//       .read(discoverRepositoryProvider)
//       .discover(
//         latitude: position.latitude,
//         longitude: position.longitude,
//         excludedIds: excludedIds,
//         startRadius: nearbyResult?.usedRadius ?? 100000,
//       );
// });

// final discoverSearchProvider =
//     FutureProvider.autoDispose.family<List<DestinationModel>, String>((ref, query) async {
//   final q = query.trim().toLowerCase();
//   if (q.isEmpty) return [];

//   // Debounce API requests: wait for 300ms before starting search
//   var isDisposed = false;
//   ref.onDispose(() {
//     isDisposed = true;
//   });

//   await Future.delayed(const Duration(milliseconds: 300));
//   if (isDisposed) {
//     return [];
//   }

//   // Fetch live search results
//   List<DestinationModel> apiResults = [];
//   try {
//     apiResults = await ref.read(discoverRepositoryProvider).search(query);
//   } catch (_) {}

//   // Get other destinations from providers (if loaded)
//   final nearbyDestinations = ref.read(nearbyDestinationsProvider).valueOrNull?.destinations ?? [];
//   final discoverDestinations = ref.read(discoverDestinationsProvider).valueOrNull ?? [];
//   final popularDestinations = ref.read(popularDestinationsProvider).valueOrNull ?? [];

//   // Combine all destinations
//   final allDestinations = [
//     ...apiResults,
//     ...nearbyDestinations,
//     ...discoverDestinations,
//     ...popularDestinations,
//   ];

//   // Remove duplicates (by ID, title+location, or coordinates)
//   final unique = <String>{};
//   final uniqueCoords = <String>{};
//   final deduped = <DestinationModel>[];

//   for (final d in allDestinations) {
//     final idKey = d.id;
//     final titleKey = "${d.title.trim().toLowerCase()}_${d.location.trim().toLowerCase()}";
//     final coordKey = "${d.latitude.toStringAsFixed(4)}_${d.longitude.toStringAsFixed(4)}";

//     if (unique.contains(idKey) || unique.contains(titleKey) || uniqueCoords.contains(coordKey)) {
//       continue;
//     }

//     unique.add(idKey);
//     unique.add(titleKey);
//     uniqueCoords.add(coordKey);
//     deduped.add(d);
//   }

//   // Filter by query (case-insensitive match in title, location, description, or categories)
//   final filtered = deduped.where((d) {
//     final titleMatch = d.title.toLowerCase().contains(q);
//     final locationMatch = d.location.toLowerCase().contains(q);
//     final descMatch = d.description.toLowerCase().contains(q);
//     final catMatch = d.categories.any((c) => c.toLowerCase().contains(q));
//     return titleMatch || locationMatch || descMatch || catMatch;
//   }).toList();

//   // Get user location for ranking
//   final userLoc = ref.read(popularCountryProvider).valueOrNull;

//   // Rank matches
//   filtered.sort((a, b) {
//     final scoreA = _calculateSearchScore(a, q, userLoc);
//     final scoreB = _calculateSearchScore(b, q, userLoc);
//     return scoreB.compareTo(scoreA); // Descending order
//   });

//   return filtered;
// });

// int _calculateSearchScore(DestinationModel d, String q, LocationModel? userLoc) {
//   int score = 0;
//   final titleLower = d.title.toLowerCase();
//   final locationLower = d.location.toLowerCase();

//   // 1. Exact title match
//   if (titleLower == q) {
//     score += 100000;
//   } else if (titleLower.startsWith(q)) {
//     score += 50000;
//   }

//   if (userLoc != null) {
//     // 2. Same city
//     if (userLoc.city.isNotEmpty && locationLower.contains(userLoc.city.toLowerCase())) {
//       score += 10000;
//     }
//     // 3. Same state
//     if (userLoc.state.isNotEmpty && locationLower.contains(userLoc.state.toLowerCase())) {
//       score += 5000;
//     }
//     // 4. Same country
//     if (userLoc.country.isNotEmpty && locationLower.contains(userLoc.country.toLowerCase())) {
//       score += 1000;
//     }
//   }

//   // 5. Tourism category importance weight
//   final catString = d.categories.join(" ").toLowerCase();
//   if (catString.contains('unesco') || titleLower.contains('unesco')) score += 5000;
//   if (catString.contains('castle') || titleLower.contains('castle')) score += 4000;
//   if (catString.contains('fort') || titleLower.contains('fort')) score += 4000;
//   if (catString.contains('palace') || titleLower.contains('palace')) score += 3500;
//   if (catString.contains('monument') || titleLower.contains('monument')) score += 3000;
//   if (catString.contains('museum') || titleLower.contains('museum')) score += 2500;
//   if (catString.contains('temple') || titleLower.contains('temple')) score += 2000;
//   if (catString.contains('church') || titleLower.contains('church')) score += 2000;
//   if (catString.contains('mosque') || titleLower.contains('mosque')) score += 2000;
//   if (catString.contains('heritage') || titleLower.contains('heritage')) score += 1500;

//   // 6. Partial matches
//   if (titleLower.contains(q)) {
//     score += 100;
//   }
//   if (locationLower.contains(q)) {
//     score += 50;
//   }

//   return score;
// }


import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/destination_model.dart';
import '../data/models/location_model.dart';
import 'home_provider.dart';
import 'nearby_destinations_provider.dart';
import 'popular_provider.dart';

final discoverDestinationsProvider =
    FutureProvider<List<DestinationModel>>((ref) async {
  final destinations = await ref
      .read(voyaraLocalDataSourceProvider)
      .getDestinations();

  final nearbyResult =
      ref.watch(nearbyDestinationsProvider).valueOrNull;

  final excludedIds =
      nearbyResult?.destinations.map((e) => e.id).toSet() ?? {};

  final available = destinations.where((destination) {
    return !excludedIds.contains(destination.id) &&
        destination.title.trim().isNotEmpty &&
        destination.latitude != 0 &&
        destination.longitude != 0;
  }).toList();

  // Show highly rated destinations first.
  available.sort(
    (a, b) => b.rating.compareTo(a.rating),
  );

  return available.take(8).toList();
});

final discoverSearchProvider =
    FutureProvider.autoDispose.family<List<DestinationModel>, String>(
  (ref, query) async {
    final q = query.trim().toLowerCase();

    if (q.isEmpty) {
      return [];
    }

    // Keep the existing 300 ms debounce.
    var isDisposed = false;

    ref.onDispose(() {
      isDisposed = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 300),
    );

    if (isDisposed) {
      return [];
    }

    // Read ALL destinations from our curated dataset.
    final destinations = await ref
        .read(voyaraLocalDataSourceProvider)
        .getDestinations();

    // Filter locally instead of calling Geoapify.
    final filtered = destinations.where((destination) {
      final titleMatch =
          destination.title.toLowerCase().contains(q);

      final locationMatch =
          destination.location.toLowerCase().contains(q);

      final descriptionMatch =
          destination.description.toLowerCase().contains(q);

      final categoryMatch = destination.categories.any(
        (category) =>
            category.toString().toLowerCase().contains(q),
      );

      final activityMatch =
          destination.toMap()['activities']
                  ?.toString()
                  .toLowerCase()
                  .contains(q) ??
              false;

      return titleMatch ||
          locationMatch ||
          descriptionMatch ||
          categoryMatch ||
          activityMatch;
    }).toList();

    // Get user's location for ranking.
    final userLoc =
        ref.read(popularCountryProvider).valueOrNull;

    filtered.sort((a, b) {
      final scoreA =
          _calculateSearchScore(a, q, userLoc);

      final scoreB =
          _calculateSearchScore(b, q, userLoc);

      return scoreB.compareTo(scoreA);
    });

    return filtered;
  },
);

int _calculateSearchScore(
  DestinationModel destination,
  String query,
  LocationModel? userLoc,
) {
  int score = 0;

  final title =
      destination.title.toLowerCase();

  final location =
      destination.location.toLowerCase();

  // Exact title match.
  if (title == query) {
    score += 100000;
  } else if (title.startsWith(query)) {
    score += 50000;
  }

  // User location relevance.
  if (userLoc != null) {
    if (userLoc.city.isNotEmpty &&
        location.contains(userLoc.city.toLowerCase())) {
      score += 10000;
    }

    if (userLoc.state.isNotEmpty &&
        location.contains(userLoc.state.toLowerCase())) {
      score += 5000;
    }

    if (userLoc.country.isNotEmpty &&
        location.contains(userLoc.country.toLowerCase())) {
      score += 1000;
    }
  }

  // Tourism importance.
  final categories =
      destination.categories.join(" ").toLowerCase();

  if (categories.contains('unesco') ||
      title.contains('unesco')) {
    score += 5000;
  }

  if (categories.contains('castle') ||
      title.contains('castle')) {
    score += 4000;
  }

  if (categories.contains('fort') ||
      title.contains('fort')) {
    score += 4000;
  }

  if (categories.contains('palace') ||
      title.contains('palace')) {
    score += 3500;
  }

  if (categories.contains('monument') ||
      title.contains('monument')) {
    score += 3000;
  }

  if (categories.contains('museum') ||
      title.contains('museum')) {
    score += 2500;
  }

  if (categories.contains('temple') ||
      title.contains('temple')) {
    score += 2000;
  }

  if (categories.contains('church') ||
      title.contains('church')) {
    score += 2000;
  }

  if (categories.contains('mosque') ||
      title.contains('mosque')) {
    score += 2000;
  }

  if (categories.contains('heritage') ||
      title.contains('heritage')) {
    score += 1500;
  }

  // Partial matches.
  if (title.contains(query)) {
    score += 100;
  }

  if (location.contains(query)) {
    score += 50;
  }

  // Rating as a small tie-breaker.
  score += (destination.rating * 10).round();

  return score;
}