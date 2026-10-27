import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../data/models/search_filter_model.dart';
import '../../providers/search_filter_provider.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FilterBottomSheet(),
    );
  }

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late String? _selectedCategory;
  late double? _maxPrice;
  late double? _minRating;
  late SortOption _sortOption;

  @override
  void initState() {
    super.initState();
    final current = ref.read(searchFilterProvider);
    _selectedCategory = current.category;
    _maxPrice = current.maxPrice;
    _minRating = current.minRating;
    _sortOption = current.sortOption;
  }

  void _clearAll() {
    setState(() {
      _selectedCategory = null;
      _maxPrice = null;
      _minRating = null;
      _sortOption = SortOption.relevance;
    });
  }

  void _apply() {
    final newState = SearchFilterState(
      category: _selectedCategory,
      maxPrice: _maxPrice,
      minRating: _minRating,
      sortOption: _sortOption,
    );
    ref.read(searchFilterProvider.notifier).applyFilter(newState);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoriesAsync = ref.watch(availableCategoriesProvider);
    final maxAvailablePriceAsync = ref.watch(availableMaxPriceProvider);
    final maxLimit = maxAvailablePriceAsync.value ?? 500.0;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 6),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      "Filters",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _clearAll,
                      child: Text(
                        "Clear All",
                        style: TextStyle(
                          color: isDark ? AppColors.secondary : AppColors.tertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Scrollable Filters
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  children: [
                    // 1. CATEGORY
                    Text(
                      "Category",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    categoriesAsync.when(
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (_, _) => const Text("Could not load categories"),
                      data: (categories) {
                        final allCategories = [
                          'All',
                          'Beaches',
                          'Temples',
                          'Mountains',
                          'Waterfalls',
                          'Museums',
                          'Parks',
                          'Adventure',
                          'Wildlife',
                          ...categories.where((c) => ![
                                'All',
                                'Beaches',
                                'Temples',
                                'Mountains',
                                'Waterfalls',
                                'Museums',
                                'Parks',
                                'Adventure',
                                'Wildlife'
                              ].contains(c)),
                        ];

                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: allCategories.map((category) {
                            final isSelected = category == 'All'
                                ? (_selectedCategory == null || _selectedCategory == 'All')
                                : _selectedCategory == category;

                            return ChoiceChip(
                              label: Text(category),
                              selected: isSelected,
                              selectedColor: isDark ? AppColors.secondary : AppColors.primary,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? (isDark ? AppColors.primaryDark : Colors.white)
                                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 13,
                              ),
                              onSelected: (_) {
                                setState(() {
                                  _selectedCategory = category == 'All' ? null : category;
                                });
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 26),

                    // 2. PRICE RANGE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Price Range",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          _maxPrice == null
                              ? "Any"
                              : (_maxPrice == 0
                                  ? "Free only"
                                  : "Up to ₹${_maxPrice!.round()}"),
                          style: TextStyle(
                            color: isDark ? AppColors.secondary : AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: isDark ? AppColors.secondary : AppColors.primary,
                        thumbColor: isDark ? AppColors.secondary : AppColors.primary,
                        inactiveTrackColor: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                      child: Slider(
                        value: (_maxPrice ?? maxLimit).clamp(0.0, maxLimit),
                        min: 0,
                        max: maxLimit,
                        divisions: maxLimit > 100 ? (maxLimit / 25).round() : 10,
                        label: _maxPrice == null
                            ? "Any"
                            : (_maxPrice == 0 ? "Free" : "₹${_maxPrice!.round()}"),
                        onChanged: (val) {
                          setState(() {
                            _maxPrice = val;
                          });
                        },
                      ),
                    ),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text("Any"),
                          selected: _maxPrice == null,
                          onSelected: (selected) {
                            if (selected) setState(() => _maxPrice = null);
                          },
                        ),
                        ChoiceChip(
                          label: const Text("Free"),
                          selected: _maxPrice == 0.0,
                          onSelected: (selected) {
                            if (selected) setState(() => _maxPrice = 0.0);
                          },
                        ),
                        if (maxLimit >= 50)
                          ChoiceChip(
                            label: const Text("< ₹50"),
                            selected: _maxPrice == 50.0,
                            onSelected: (selected) {
                              setState(() => _maxPrice = selected ? 50.0 : null);
                            },
                          ),
                        if (maxLimit >= 100)
                          ChoiceChip(
                            label: const Text("< ₹100"),
                            selected: _maxPrice == 100.0,
                            onSelected: (selected) {
                              setState(() => _maxPrice = selected ? 100.0 : null);
                            },
                          ),
                        if (maxLimit >= 250)
                          ChoiceChip(
                            label: const Text("< ₹250"),
                            selected: _maxPrice == 250.0,
                            onSelected: (selected) {
                              setState(() => _maxPrice = selected ? 250.0 : null);
                            },
                          ),
                      ],
                    ),

                    const SizedBox(height: 26),

                    // 3. MINIMUM RATING
                    Text(
                      "Minimum Rating",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text("Any"),
                          selected: _minRating == null,
                          onSelected: (selected) {
                            if (selected) setState(() => _minRating = null);
                          },
                        ),
                        ChoiceChip(
                          avatar: const Icon(Icons.star_rounded, size: 16, color: AppColors.star),
                          label: const Text("3.0+"),
                          selected: _minRating == 3.0,
                          onSelected: (selected) {
                            setState(() => _minRating = selected ? 3.0 : null);
                          },
                        ),
                        ChoiceChip(
                          avatar: const Icon(Icons.star_rounded, size: 16, color: AppColors.star),
                          label: const Text("4.0+"),
                          selected: _minRating == 4.0,
                          onSelected: (selected) {
                            setState(() => _minRating = selected ? 4.0 : null);
                          },
                        ),
                        ChoiceChip(
                          avatar: const Icon(Icons.star_rounded, size: 16, color: AppColors.star),
                          label: const Text("4.5+"),
                          selected: _minRating == 4.5,
                          onSelected: (selected) {
                            setState(() => _minRating = selected ? 4.5 : null);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 26),

                    // 4. SORT BY
                    Text(
                      "Sort By",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: SortOption.values.map((option) {
                        final isSelected = _sortOption == option;
                        return ChoiceChip(
                          label: Text(option.label),
                          selected: isSelected,
                          selectedColor: isDark ? AppColors.secondary : AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? (isDark ? AppColors.primaryDark : Colors.white)
                                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _sortOption = option);
                            }
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Bottom Fixed Button
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 1,
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _apply,
                    style: FilledButton.styleFrom(
                      backgroundColor: isDark ? AppColors.secondary : AppColors.primary,
                      foregroundColor: isDark ? AppColors.primaryDark : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: const Text(
                      "Apply Filters",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
