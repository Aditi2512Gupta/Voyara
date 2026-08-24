import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/similar_destinations_provider.dart';
import 'destination_card.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import 'loading_destinations.dart';

class SimilarDestinationsSection extends ConsumerWidget {
  const SimilarDestinationsSection({
    super.key,
    required this.category,
    required this.currentDestinationId,
  });

  final String category;
  final String currentDestinationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destinations = ref.watch(similarDestinationsProvider(category));

    return destinations.when(
      loading: () => const LoadingDestinations(),

      error: (error, stackTrace) => AppErrorWidget(
        message: error.toString(),
        onRetry: () {
          ref.invalidate(similarDestinationsProvider(category));
        },
      ),

      data: (list) {
        final similar = list
            .where((item) => item.id != currentDestinationId)
            .toList();

        if (similar.isEmpty) {
          return const EmptyStateWidget(
            message: "No similar destinations found.",
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Similar Destinations",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 280,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: similar.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  return DestinationCard(destination: similar[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
