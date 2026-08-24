import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/recently_viewed_provider.dart';
import 'destination_card.dart';
import 'section_title.dart';

class RecentlyViewedSection extends ConsumerWidget {
  const RecentlyViewedSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destinations = ref.watch(recentlyViewedProvider);

    if (destinations.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: "Recently Viewed",
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: 280,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: destinations.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: 16),
            itemBuilder: (_, index) {
              return DestinationCard(
                destination: destinations[index],
              );
            },
          ),
        ),
      ],
    );
  }
}