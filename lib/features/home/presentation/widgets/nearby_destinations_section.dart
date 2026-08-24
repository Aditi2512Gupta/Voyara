import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/nearby_destinations_provider.dart';
import 'destination_card.dart';

class NearbyDestinationsSection extends ConsumerWidget {
  const NearbyDestinationsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearby = ref.watch(nearbyDestinationsProvider);

    return nearby.when(
      loading: () => const Center(child: CircularProgressIndicator()),

      error: (error, _) => Center(child: Text(error.toString())),

      data: (result) {
        if (result.destinations.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "📍 Nearby You",
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 280,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
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
