import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/selected_category_provider.dart';
import '../../providers/category_list_provider.dart';
import 'category_chip.dart';

class CategoryList extends ConsumerWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCategoryProvider);
    final categoriesAsync = ref.watch(categoryListProvider);

    return SizedBox(
      height: 42,
      child: categoriesAsync.when(
        loading: () => const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),

        error: (error, _) => Center(
          child: Text(error.toString()),
        ),

        data: (categories) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];

              final isSelected =
                  (category == "All" && selected == null) ||
                  selected == category;

              return CategoryChip(
                label: category,
                selected: isSelected,
                onTap: () {
                  ref.read(selectedCategoryProvider.notifier).state =
                      category == "All" ? null : category;
                },
              );
            },
          );
        },
      ),
    );
  }
}