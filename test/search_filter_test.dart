import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voyara/features/home/data/models/destination_model.dart';
import 'package:voyara/features/home/data/models/search_filter_model.dart';
import 'package:voyara/features/home/providers/discover_provider.dart';
import 'package:voyara/features/home/providers/search_filter_provider.dart';
import 'package:voyara/features/home/providers/selected_category_provider.dart';

void main() {
  group('SearchFilterModel & SortOption Tests', () {
    test('Default SearchFilterState has no active filters', () {
      const state = SearchFilterState();

      expect(state.category, isNull);
      expect(state.maxPrice, isNull);
      expect(state.minRating, isNull);
      expect(state.sortOption, SortOption.relevance);
      expect(state.hasActiveFilters, isFalse);
      expect(state.activeFilterCount, 0);
    });

    test('hasActiveFilters and activeFilterCount accurately reflect active criteria', () {
      final state1 = const SearchFilterState().copyWith(category: () => 'Beach');
      expect(state1.hasActiveFilters, isTrue);
      expect(state1.activeFilterCount, 1);

      final state2 = state1.copyWith(maxPrice: () => 150.0);
      expect(state2.hasActiveFilters, isTrue);
      expect(state2.activeFilterCount, 2);

      final state3 = state2.copyWith(minRating: () => 4.0);
      expect(state3.hasActiveFilters, isTrue);
      expect(state3.activeFilterCount, 3);

      final state4 = state3.copyWith(sortOption: SortOption.priceLowToHigh);
      expect(state4.hasActiveFilters, isTrue);
      expect(state4.activeFilterCount, 4);

      final state5 = const SearchFilterState(category: 'All');
      expect(state5.hasActiveFilters, isFalse);
      expect(state5.activeFilterCount, 0);
    });

    test('copyWith handles resetting nullable values', () {
      final state = const SearchFilterState(
        category: 'Nature',
        maxPrice: 200,
        minRating: 4.5,
        sortOption: SortOption.highestRated,
      );

      final cleared = state.copyWith(
        category: () => null,
        maxPrice: () => null,
        minRating: () => null,
        sortOption: SortOption.relevance,
      );

      expect(cleared.category, isNull);
      expect(cleared.maxPrice, isNull);
      expect(cleared.minRating, isNull);
      expect(cleared.sortOption, SortOption.relevance);
      expect(cleared.hasActiveFilters, isFalse);
    });

    test('reset returns initial state', () {
      final state = const SearchFilterState(
        category: 'Nature',
        maxPrice: 200,
        minRating: 4.5,
        sortOption: SortOption.highestRated,
      ).reset();

      expect(state.category, isNull);
      expect(state.maxPrice, isNull);
      expect(state.minRating, isNull);
      expect(state.sortOption, SortOption.relevance);
    });
  });

  group('SearchFilterNotifier & Riverpod State Sync Tests', () {
    test('Setting category syncs with selectedCategoryProvider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(searchFilterProvider.notifier);

      notifier.setCategory('Monument');
      expect(container.read(searchFilterProvider).category, 'Monument');
      expect(container.read(selectedCategoryProvider), 'Monument');

      notifier.clearCategory();
      expect(container.read(searchFilterProvider).category, isNull);
      expect(container.read(selectedCategoryProvider), isNull);
    });

    test('Setting maxPrice, minRating and sort updates state correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(searchFilterProvider.notifier);

      notifier.setMaxPrice(100.0);
      expect(container.read(searchFilterProvider).maxPrice, 100.0);

      notifier.setMinRating(4.5);
      expect(container.read(searchFilterProvider).minRating, 4.5);

      notifier.setSortOption(SortOption.highestRated);
      expect(container.read(searchFilterProvider).sortOption, SortOption.highestRated);

      notifier.clearMaxPrice();
      expect(container.read(searchFilterProvider).maxPrice, isNull);

      notifier.clearMinRating();
      expect(container.read(searchFilterProvider).minRating, isNull);

      notifier.clearSort();
      expect(container.read(searchFilterProvider).sortOption, SortOption.relevance);
    });

    test('clearAll resets all filters and clears selectedCategoryProvider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(searchFilterProvider.notifier);
      notifier.setCategory('Heritage Site');
      notifier.setMaxPrice(50.0);
      notifier.setMinRating(4.0);
      notifier.setSortOption(SortOption.priceHighToLow);

      expect(container.read(searchFilterProvider).hasActiveFilters, isTrue);
      expect(container.read(selectedCategoryProvider), 'Heritage Site');

      notifier.clearAll();

      expect(container.read(searchFilterProvider).hasActiveFilters, isFalse);
      expect(container.read(searchFilterProvider).category, isNull);
      expect(container.read(searchFilterProvider).maxPrice, isNull);
      expect(container.read(searchFilterProvider).minRating, isNull);
      expect(container.read(searchFilterProvider).sortOption, SortOption.relevance);
      expect(container.read(selectedCategoryProvider), isNull);
    });
  });

  group('Filtering and Sorting Logic Tests', () {
    final destinations = [
      const DestinationModel(
        id: '1',
        title: 'Amber Palace',
        location: 'Jaipur, Rajasthan',
        imageUrl: '',
        rating: 4.6,
        price: 100.0,
        description: 'Historic palace in Jaipur',
        categories: ['Monument', 'Heritage Site'],
        includes: [],
        reviews: [],
        latitude: 26.9855,
        longitude: 75.8513,
      ),
      const DestinationModel(
        id: '2',
        title: 'Baga Beach',
        location: 'Goa',
        imageUrl: '',
        rating: 4.2,
        price: 0.0,
        description: 'Vibrant beach in North Goa',
        categories: ['Beach', 'Nightlife'],
        includes: [],
        reviews: [],
        latitude: 15.5553,
        longitude: 73.7517,
      ),
      const DestinationModel(
        id: '3',
        title: 'Corbett National Park',
        location: 'Uttarakhand',
        imageUrl: '',
        rating: 4.8,
        price: 300.0,
        description: 'Famous tiger reserve wildlife sanctuary',
        categories: ['National Park', 'Wildlife'],
        includes: [],
        reviews: [],
        latitude: 29.5300,
        longitude: 78.7747,
      ),
    ];

    test('Filters by Category correctly', () {
      final filtered = destinations.where((d) {
        return d.categories.any((c) => c.toString().toLowerCase() == 'beach');
      }).toList();

      expect(filtered.length, 1);
      expect(filtered.first.title, 'Baga Beach');
    });

    test('Filters by Maximum Price correctly', () {
      final under150 = destinations.where((d) => (d.price ?? 0) <= 150.0).toList();
      expect(under150.length, 2);
      expect(under150.map((d) => d.title), containsAll(['Amber Palace', 'Baga Beach']));

      final freeOnly = destinations.where((d) => (d.price ?? 0) <= 0.0).toList();
      expect(freeOnly.length, 1);
      expect(freeOnly.first.title, 'Baga Beach');
    });

    test('Filters by Minimum Rating correctly', () {
      final rating45Plus = destinations.where((d) => d.rating >= 4.5).toList();
      expect(rating45Plus.length, 2);
      expect(rating45Plus.map((d) => d.title), containsAll(['Amber Palace', 'Corbett National Park']));
    });

    test('Sorts by Highest Rated', () {
      final list = List<DestinationModel>.from(destinations);
      list.sort((a, b) => b.rating.compareTo(a.rating));

      expect(list[0].title, 'Corbett National Park');
      expect(list[1].title, 'Amber Palace');
      expect(list[2].title, 'Baga Beach');
    });

    test('Sorts by Price Low to High', () {
      final list = List<DestinationModel>.from(destinations);
      list.sort((a, b) => (a.price ?? 0.0).compareTo(b.price ?? 0.0));

      expect(list[0].title, 'Baga Beach'); // 0.0
      expect(list[1].title, 'Amber Palace'); // 100.0
      expect(list[2].title, 'Corbett National Park'); // 300.0
    });

    test('Sorts by Price High to Low', () {
      final list = List<DestinationModel>.from(destinations);
      list.sort((a, b) => (b.price ?? 0.0).compareTo(a.price ?? 0.0));

      expect(list[0].title, 'Corbett National Park'); // 300.0
      expect(list[1].title, 'Amber Palace'); // 100.0
      expect(list[2].title, 'Baga Beach'); // 0.0
    });

    test('Sorts by Name A-Z', () {
      final list = List<DestinationModel>.from(destinations);
      list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

      expect(list[0].title, 'Amber Palace');
      expect(list[1].title, 'Baga Beach');
      expect(list[2].title, 'Corbett National Park');
    });

    test('calculateSearchScore awards higher scores to exact matches', () {
      final scoreA = calculateSearchScore(destinations[0], 'amber', null);
      final scoreB = calculateSearchScore(destinations[1], 'amber', null);

      expect(scoreA > scoreB, isTrue);
    });
  });
}
