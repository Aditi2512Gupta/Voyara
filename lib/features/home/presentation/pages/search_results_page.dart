import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../data/models/search_filter_model.dart';
import '../../providers/recent_search_provider.dart';
import '../../providers/search_filter_provider.dart';
import '../../providers/search_provider.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/search_destination_card.dart';

class SearchResultsPage extends ConsumerStatefulWidget {
  const SearchResultsPage({super.key});

  @override
  ConsumerState<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends ConsumerState<SearchResultsPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(searchQueryProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    ref.read(searchQueryProvider.notifier).state = value;
  }

  Widget _buildActiveFiltersBar(
    SearchFilterState filter,
    SearchFilterNotifier notifier,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Filter pills from mockup
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text("All"),
              selected: filter.category == null || filter.category == 'All',
              onSelected: (_) => notifier.clearCategory(),
              selectedColor: isDark ? AppColors.secondary : AppColors.primary,
              labelStyle: TextStyle(
                color: (filter.category == null || filter.category == 'All')
                    ? (isDark ? AppColors.primaryDark : Colors.white)
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textPrimaryLight),
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text("Attractions"),
              selected: filter.category == 'Attraction',
              onSelected: (selected) {
                if (selected) {
                  notifier.setCategory('Attraction');
                } else {
                  notifier.clearCategory();
                }
              },
              selectedColor: isDark ? AppColors.secondary : AppColors.primary,
              labelStyle: TextStyle(
                color: filter.category == 'Attraction'
                    ? (isDark ? AppColors.primaryDark : Colors.white)
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textPrimaryLight),
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text("Destinations"),
              selected: filter.category == 'Destination',
              onSelected: (selected) {
                if (selected) {
                  notifier.setCategory('Destination');
                } else {
                  notifier.clearCategory();
                }
              },
              selectedColor: isDark ? AppColors.secondary : AppColors.primary,
              labelStyle: TextStyle(
                color: filter.category == 'Destination'
                    ? (isDark ? AppColors.primaryDark : Colors.white)
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textPrimaryLight),
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ),

          // Clear all button if custom filters active
          if (filter.hasActiveFilters) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                avatar: const Icon(Icons.close, size: 14),
                label: const Text("Clear all"),
                onPressed: () => notifier.clearAll(),
              ),
            ),

            if (filter.category != null &&
                filter.category!.isNotEmpty &&
                filter.category != 'All' &&
                filter.category != 'Attraction' &&
                filter.category != 'Destination')
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InputChip(
                  label: Text("${filter.category}"),
                  onDeleted: () => notifier.clearCategory(),
                ),
              ),

            if (filter.maxPrice != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InputChip(
                  label: Text(
                    filter.maxPrice == 0
                        ? "Free only"
                        : "Under ₹${filter.maxPrice!.round()}",
                  ),
                  onDeleted: () => notifier.clearMaxPrice(),
                ),
              ),

            if (filter.minRating != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InputChip(
                  label: Text("★ ${filter.minRating!.toStringAsFixed(1)}+"),
                  onDeleted: () => notifier.clearMinRating(),
                ),
              ),

            if (filter.sortOption != SortOption.relevance)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InputChip(
                  label: Text("${filter.sortOption.label}"),
                  onDeleted: () => notifier.clearSort(),
                ),
              ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final filter = ref.watch(searchFilterProvider);
    final filterNotifier = ref.read(searchFilterProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_controller.text != query) {
      _controller.text = query;
    }

    final recentSearches = ref.watch(recentSearchProvider);
    final searchResultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Container(
          height: 44,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.inputDark : AppColors.inputLight,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1,
            ),
          ),
          child: TextField(
            controller: _controller,
            autofocus: query.isEmpty && !filter.hasActiveFilters,
            textInputAction: TextInputAction.search,
            style: TextStyle(
              fontSize: 14.5,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            decoration: InputDecoration(
              hintText: "Search destinations...",
              prefixIcon: Icon(
                Icons.search,
                size: 20,
                color: isDark ? AppColors.secondary : AppColors.primary,
              ),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        _controller.clear();
                        _onQueryChanged("");
                      },
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              isDense: true,
              filled: false,
            ),
            onChanged: _onQueryChanged,
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                ref.read(recentSearchProvider.notifier).addSearch(value);
              }
            },
          ),
        ),
        actions: [
          // Filter button
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => FilterBottomSheet.show(context),
              borderRadius: BorderRadius.circular(22),
              child: Badge(
                isLabelVisible: filter.hasActiveFilters,
                backgroundColor: AppColors.tertiary,
                label: Text('${filter.activeFilterCount}'),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.secondary : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.tune,
                    size: 20,
                    color: isDark ? AppColors.primaryDark : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Active filter pills bar
          _buildActiveFiltersBar(filter, filterNotifier),

          const SizedBox(height: 6),

          // Results list / Empty state
          Expanded(
            child: searchResultsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text("Error: $e"),
                ),
              ),
              data: (places) {
                if (places == null) {
                  if (recentSearches.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.travel_explore,
                            size: 64,
                            color: AppColors.textTertiaryLight,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Start typing to search destinations",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Recent Searches",
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          TextButton(
                            onPressed: () {
                              ref.read(recentSearchProvider.notifier).clear();
                            },
                            child: const Text("Clear"),
                          ),
                        ],
                      ),
                      ...recentSearches.map(
                        (item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.history, size: 20),
                          title: Text(item.query),
                          trailing: const Icon(Icons.arrow_outward, size: 16),
                          onTap: () {
                            _controller.text = item.query;
                            _onQueryChanged(item.query);
                          },
                        ),
                      ),
                    ],
                  );
                }

                if (places.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: AppColors.textTertiaryLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No destinations found",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Try adjusting your filters or search terms",
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textTertiaryLight,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    final destination = places[index];
                    return SearchDestinationCard(
                      destination: destination,
                      onTap: () {
                        context.push('/destination', extra: destination);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
