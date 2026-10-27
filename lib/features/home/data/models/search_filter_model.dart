enum SortOption {
  relevance('Relevance'),
  highestRated('Highest Rated'),
  priceLowToHigh('Price: Low to High'),
  priceHighToLow('Price: High to Low'),
  nameAZ('Name (A-Z)');

  final String label;
  const SortOption(this.label);
}

class SearchFilterState {
  final String? category;
  final double? maxPrice;
  final double? minRating;
  final SortOption sortOption;

  const SearchFilterState({
    this.category,
    this.maxPrice,
    this.minRating,
    this.sortOption = SortOption.relevance,
  });

  bool get hasActiveFilters =>
      (category != null && category!.isNotEmpty && category != 'All') ||
      maxPrice != null ||
      minRating != null ||
      sortOption != SortOption.relevance;

  int get activeFilterCount {
    int count = 0;
    if (category != null && category!.isNotEmpty && category != 'All') count++;
    if (maxPrice != null) count++;
    if (minRating != null) count++;
    if (sortOption != SortOption.relevance) count++;
    return count;
  }

  SearchFilterState copyWith({
    String? Function()? category,
    double? Function()? maxPrice,
    double? Function()? minRating,
    SortOption? sortOption,
  }) {
    return SearchFilterState(
      category: category != null ? category() : this.category,
      maxPrice: maxPrice != null ? maxPrice() : this.maxPrice,
      minRating: minRating != null ? minRating() : this.minRating,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  SearchFilterState reset() => const SearchFilterState();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchFilterState &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          maxPrice == other.maxPrice &&
          minRating == other.minRating &&
          sortOption == other.sortOption;

  @override
  int get hashCode =>
      category.hashCode ^
      maxPrice.hashCode ^
      minRating.hashCode ^
      sortOption.hashCode;
}
