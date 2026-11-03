import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/destination_model.dart';
import '../data/models/search_filter_model.dart';
import 'discover_provider.dart';
import 'home_provider.dart';
import 'popular_provider.dart';
import 'search_provider.dart';
import 'selected_category_provider.dart';

final searchFilterProvider =
    StateNotifierProvider<SearchFilterNotifier, SearchFilterState>((ref) {
      return SearchFilterNotifier(ref);
    });

class SearchFilterNotifier extends StateNotifier<SearchFilterState> {
  SearchFilterNotifier(this.ref) : super(const SearchFilterState()) {
    // If selectedCategoryProvider has an initial value, sync it
    final initialCat = ref.read(selectedCategoryProvider);
    if (initialCat != null && initialCat.isNotEmpty && initialCat != 'All') {
      state = state.copyWith(category: () => initialCat);
    }
  }

  final Ref ref;

  void setCategory(String? category) {
    final cat = (category == null || category == 'All') ? null : category;
    state = state.copyWith(category: () => cat);
    ref.read(selectedCategoryProvider.notifier).state = cat;
  }

  void setMaxPrice(double? maxPrice) {
    state = state.copyWith(maxPrice: () => maxPrice);
  }

  void setMinRating(double? minRating) {
    state = state.copyWith(minRating: () => minRating);
  }

  void setSortOption(SortOption sortOption) {
    state = state.copyWith(sortOption: sortOption);
  }

  void applyFilter(SearchFilterState newState) {
    state = newState;
    ref.read(selectedCategoryProvider.notifier).state = newState.category;
  }

  void clearCategory() {
    setCategory(null);
  }

  void clearMaxPrice() {
    state = state.copyWith(maxPrice: () => null);
  }

  void clearMinRating() {
    state = state.copyWith(minRating: () => null);
  }

  void clearSort() {
    state = state.copyWith(sortOption: SortOption.relevance);
  }

  void clearAll() {
    state = const SearchFilterState();
    ref.read(selectedCategoryProvider.notifier).state = null;
  }
}

// All destinations provider from curated local dataset
final allDestinationsProvider = FutureProvider<List<DestinationModel>>((
  ref,
) async {
  final dataSource = ref.watch(voyaraLocalDataSourceProvider);
  final destinations = await dataSource.getDestinations();
  return destinations.where((d) {
    return d.title.trim().isNotEmpty && d.latitude != 0 && d.longitude != 0;
  }).toList();
});

// Dynamic available categories provider from the dataset
final availableCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final destinations = await ref.watch(allDestinationsProvider.future);
  final categories =
      destinations
          .expand((d) => d.categories)
          .map((c) => c.toString().trim())
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
  return categories;
});

// Dynamic available maximum price provider from the dataset
final availableMaxPriceProvider = FutureProvider<double>((ref) async {
  final destinations = await ref.watch(allDestinationsProvider.future);
  double max = 0.0;
  for (final d in destinations) {
    if (d.price != null && d.price! > max) {
      max = d.price!;
    }
  }
  return max > 0 ? max : 500.0;
});

// Integrated search and filter provider
final searchResultsProvider =
    FutureProvider.autoDispose<List<DestinationModel>?>((ref) async {
      final query = ref.watch(searchQueryProvider).trim();
      final filter = ref.watch(searchFilterProvider);

      // If no query and no active filters, show recent search view
      if (query.isEmpty && !filter.hasActiveFilters) {
        return null;
      }

      // Debounce if user is actively searching
      if (query.isNotEmpty) {
        var isDisposed = false;
        ref.onDispose(() => isDisposed = true);
        await Future.delayed(const Duration(milliseconds: 300));
        if (isDisposed) return null;
      }

      final allDestinations = await ref.watch(allDestinationsProvider.future);
      final q = query.toLowerCase();

      // 1. Text filter & Relevance ranking
      List<DestinationModel> workingList;
      if (query.isNotEmpty) {
        workingList = allDestinations.where((destination) {
          final titleMatch = destination.title.toLowerCase().contains(q);
          final locationMatch = destination.location.toLowerCase().contains(q);
          final descriptionMatch = destination.description
              .toLowerCase()
              .contains(q);
          final categoryMatch = destination.categories.any(
            (c) => c.toString().toLowerCase().contains(q),
          );
          final activityMatch =
              destination
                  .toMap()['activities']
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
      } else {
        workingList = List.from(allDestinations);
      }

      // 2. Filter by Category
      if (filter.category != null &&
          filter.category!.isNotEmpty &&
          filter.category != 'All') {
        final catLower = filter.category!.toLowerCase();
        workingList = workingList.where((destination) {
          return destination.categories.any(
            (c) => c.toString().toLowerCase() == catLower,
          );
        }).toList();
      }

      // 3. Filter by Max Price
      if (filter.maxPrice != null) {
        final maxP = filter.maxPrice!;
        workingList = workingList.where((destination) {
          if (destination.price == null) return maxP >= 0;
          return destination.price! <= maxP;
        }).toList();
      }

      // 4. Filter by Min Rating
      if (filter.minRating != null) {
        final minR = filter.minRating!;
        workingList = workingList.where((destination) {
          return destination.rating >= minR;
        }).toList();
      }

      // 5. Sorting
      final userLoc = ref.read(popularCountryProvider).valueOrNull;

      switch (filter.sortOption) {
        case SortOption.relevance:
          if (query.isNotEmpty) {
            workingList.sort((a, b) {
              final scoreA = calculateSearchScore(a, q, userLoc);
              final scoreB = calculateSearchScore(b, q, userLoc);
              return scoreB.compareTo(scoreA);
            });
          } else {
            workingList.sort((a, b) => b.rating.compareTo(a.rating));
          }
          break;

        case SortOption.highestRated:
          workingList.sort((a, b) => b.rating.compareTo(a.rating));
          break;

        case SortOption.priceLowToHigh:
          workingList.sort((a, b) {
            final priceA = a.price ?? 0.0;
            final priceB = b.price ?? 0.0;
            return priceA.compareTo(priceB);
          });
          break;

        case SortOption.priceHighToLow:
          workingList.sort((a, b) {
            final priceA = a.price ?? 0.0;
            final priceB = b.price ?? 0.0;
            return priceB.compareTo(priceA);
          });
          break;

        case SortOption.nameAZ:
          workingList.sort((a, b) {
            return a.title.toLowerCase().compareTo(b.title.toLowerCase());
          });
          break;
      }

      return workingList;
    });
