import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../bookings/providers/booking_provider.dart';
import '../../providers/trip_stats_provider.dart';
import '../../providers/trips_provider.dart';
import '../widgets/trip_filter_chips.dart';
import '../widgets/trip_card.dart';

class TripsPage extends ConsumerStatefulWidget {
  const TripsPage({super.key});

  @override
  ConsumerState<TripsPage> createState() => _TripsPageState();
}

class _TripsPageState extends ConsumerState<TripsPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(bookingControllerProvider).updateCompletedTrips();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final tripsAsync = ref.watch(tripsProvider);

    final statsAsync = ref.watch(tripStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("My Trips")),
      body: tripsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, _) => Center(child: Text(error.toString())),

        data: (trips) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const TripFilterChips(),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      context.push('/trip-planner');
                    },
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Plan a Trip with AI'),
                  ),
                ),

                const SizedBox(height: 16),

                statsAsync.when(
                  data: (stats) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          Chip(
                            avatar: const Icon(Icons.flight_takeoff),
                            label: Text("Upcoming (${stats.upcoming})"),
                          ),
                          Chip(
                            avatar: const Icon(Icons.check_circle),
                            label: Text("Completed (${stats.completed})"),
                          ),
                          Chip(
                            avatar: const Icon(Icons.cancel),
                            label: Text("Cancelled (${stats.cancelled})"),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),

                const SizedBox(height: 16),

                if (trips.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.flight_takeoff,
                            size: 70,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "No trips yet",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text("Your booked trips will appear here."),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: trips.length,
                      itemBuilder: (context, index) {
                        return TripCard(trip: trips[index]);
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
