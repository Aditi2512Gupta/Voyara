import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/trip_filter.dart';
import '../../providers/trip_filter_provider.dart';

class TripFilterChips extends ConsumerWidget {
  const TripFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(tripFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: TripFilter.values.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              showCheckmark: false,
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              label: Text(
                "${filter.name[0].toUpperCase()}${filter.name.substring(1)}",
              ),
              selected: selected == filter,
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
