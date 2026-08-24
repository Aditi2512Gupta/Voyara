import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/filtered_destinations_provider.dart';
import 'featured_destination_card.dart';
import 'section_title.dart';

class RecommendedSection extends ConsumerWidget {
  const RecommendedSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destinations = ref.watch(filteredDestinationsProvider);

    if (destinations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: "Recommended For You"),

        const SizedBox(height: 16),

        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: destinations.length > 5 ? 5 : destinations.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (_, index) {
              return SizedBox(
                width: MediaQuery.of(context).size.width * .8,
                child: FeaturedDestinationCard(
                  destination: destinations[index],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
