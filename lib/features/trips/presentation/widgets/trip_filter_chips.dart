import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../data/models/trip_filter.dart';
import '../../providers/trip_filter_provider.dart';

class TripFilterChips extends ConsumerWidget {
  const TripFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(tripFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: TripFilter.values.map((filter) {
          final isSelected = selected == filter;
          final label = "${filter.name[0].toUpperCase()}${filter.name.substring(1)}";

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              showCheckmark: false,
              selectedColor: isDark ? AppColors.secondary : AppColors.primary,
              backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? (isDark ? AppColors.secondary : AppColors.primary)
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
              ),
              label: Text(label),
              labelStyle: TextStyle(
                color: isSelected
                    ? (isDark ? AppColors.primaryDark : Colors.white)
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textPrimaryLight),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
              selected: isSelected,
              onSelected: (_) {
                ref.read(tripFilterProvider.notifier).state = filter;
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
