import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/popular_provider.dart';
import '../widgets/destination_card.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';

class PopularDestinationsPage extends ConsumerWidget {
  const PopularDestinationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destinations = ref.watch(popularDestinationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Popular Destinations")),
      body: destinations.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => AppErrorWidget(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(popularDestinationsProvider);
          },
        ),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyStateWidget(message: "No destinations found.");
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DestinationCard(destination: list[index]),
              );
            },
          );
        },
      ),
    );
  }
}
