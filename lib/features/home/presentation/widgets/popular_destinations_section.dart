import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state_widget.dart';
import '../../providers/popular_provider.dart';
import 'destination_card.dart';
import 'section_title.dart';

class PopularDestinationsSection extends ConsumerWidget {
  const PopularDestinationsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popularAsync = ref.watch(popularDestinationsProvider);
    final countryAsync = ref.watch(popularCountryProvider);

    return popularAsync.when(
      loading: () => const SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator()),
      ),

      error: (e, _) => Center(child: Text(e.toString())),

      data: (destinations) {
        if (destinations.isEmpty) {
          return const EmptyStateWidget(
            message: "No popular destinations found.",
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(
              title: countryAsync.maybeWhen(
                data: (location) => "Popular in ${location.country}",
                orElse: () => "Popular Destinations",
              ),
              onSeeAll: () {
                context.push('/popular-destinations');
              },
            ),

            const SizedBox(height: 14),

            SizedBox(
              height: 255,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: destinations.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (_, index) {
                  return DestinationCard(destination: destinations[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
