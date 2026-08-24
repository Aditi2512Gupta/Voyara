import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/home_data_provider.dart';
import 'destination_card.dart';

class NearbyPlacesHomeSection extends ConsumerWidget {
  const NearbyPlacesHomeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeData = ref.watch(homeDataProvider);

    return homeData.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
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
              Text(
                "🚗 Weekend Getaways (100–300 km)",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 280,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: weekend.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (_, index) {
                    return DestinationCard(destination: weekend[index]);
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
            if (beyond.isNotEmpty) ...[
              Text(
                "✈️ Explore Beyond (300–1000 km)",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 280,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: beyond.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
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