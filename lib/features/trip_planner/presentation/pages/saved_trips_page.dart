import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/saved_trip_provider.dart';
import 'package:go_router/go_router.dart';

class SavedTripsPage extends ConsumerWidget {
  const SavedTripsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(savedTripsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Saved Trips")),
      body: tripsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, _) => Center(child: Text(error.toString())),

        data: (trips) {
          if (trips.isEmpty) {
            return const Center(child: Text("No saved trips yet."));
          }

          return ListView.builder(
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];

              return InkWell(
                onTap: () {
                  context.push('/saved-trip-details', extra: trip);
                },
                child: Card(
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.travel_explore),
                    ),

                    title: Text(
                      trip.destination,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${trip.startDate.day}/${trip.startDate.month}/${trip.startDate.year}"
                          " • ${trip.days} day${trip.days == 1 ? '' : 's'}"
                          " • ${trip.travelers} traveler${trip.travelers == 1 ? '' : 's'}",
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Budget: ₹${trip.budget.toStringAsFixed(0)}",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),

                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Delete Trip"),
                            content: const Text(
                              "Are you sure you want to delete this saved trip?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );

                        if (shouldDelete != true) return;

                        await ref
                            .read(savedTripRepositoryProvider)
                            .deleteTrip(trip.id);
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
