import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/filtered_destinations_provider.dart';
import '../../providers/discover_provider.dart';
import 'destination_card.dart';
import 'section_title.dart';

class RecommendedSection extends ConsumerWidget {
  const RecommendedSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredDestinationsProvider);
    final discoverAsync = ref.watch(discoverDestinationsProvider);

    final destinations = filtered.isNotEmpty
        ? filtered
        : discoverAsync.maybeWhen(data: (d) => d, orElse: () => []);

    if (destinations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: "✨ Recommended for You",
          onSeeAll: () {
            context.push('/search');
          },
        ),

        const SizedBox(height: 14),

        SizedBox(
          height: 255,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: destinations.length > 8 ? 8 : destinations.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (_, index) {
              return DestinationCard(destination: destinations[index]);
            },
          ),
        ),
      ],
    );
  }
}
