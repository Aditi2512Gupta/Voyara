import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/nearby_destinations_provider.dart';
import 'destination_card.dart';
import 'section_title.dart';

class NearbyDestinationsSection extends ConsumerWidget {
  const NearbyDestinationsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearby = ref.watch(nearbyDestinationsProvider);

    return nearby.when(
      loading: () => const SizedBox.shrink(),

      error: (_, __) => const SizedBox.shrink(),

      data: (result) {
        if (result.destinations.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(
              title: "Nearby Destinations",
            ),

            const SizedBox(height: 14),

            SizedBox(
              height: 255,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: result.destinations.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  return DestinationCard(
                    destination: result.destinations[index],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
