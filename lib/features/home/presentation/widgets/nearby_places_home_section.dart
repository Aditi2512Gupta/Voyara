import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/home_data_provider.dart';
import 'destination_card.dart';
import 'section_title.dart';

class NearbyPlacesHomeSection extends ConsumerWidget {
  const NearbyPlacesHomeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeData = ref.watch(homeDataProvider);

    return homeData.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => const SizedBox(),
      data: (data) {
        final weekend = data.weekendGetaways;
        final beyond = data.exploreBeyond;

        if (weekend.isEmpty && beyond.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (weekend.isNotEmpty) ...[
              const SectionTitle(title: "🚗 Weekend Getaways"),
              const SizedBox(height: 14),
              SizedBox(
                height: 255,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: weekend.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 16),
                  itemBuilder: (_, index) {
                    return DestinationCard(destination: weekend[index]);
                  },
                ),
              ),
              const SizedBox(height: 28),
            ],
            if (beyond.isNotEmpty) ...[
              const SectionTitle(title: "✈️ Explore Beyond"),
              const SizedBox(height: 14),
              SizedBox(
                height: 255,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: beyond.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 16),
                  itemBuilder: (_, index) {
                    return DestinationCard(destination: beyond[index]);
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
