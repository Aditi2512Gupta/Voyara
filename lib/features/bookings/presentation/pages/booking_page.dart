import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/services/notification_service.dart';
import '../../data/models/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../../../home/data/models/destination_model.dart';
import '../../providers/booking_loading_provider.dart';
import '../../../trips/data/models/trip_status.dart';
import '../providers/booking_form_provider.dart';

class BookingPage extends ConsumerWidget {
  const BookingPage({super.key, required this.destination});

  final DestinationModel destination;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(bookingLoadingProvider);

    final travelDate = ref.watch(travelDateProvider);

    final travelers = ref.watch(travelersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Book Trip")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            destination.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: () async {
              final selected = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime(2035),
                initialDate: DateTime.now(),
              );

              if (selected != null) {
                ref.read(travelDateProvider.notifier).state = selected;
              }
            },
            icon: const Icon(Icons.calendar_today),
            label: Text(
              travelDate == null
                  ? "Select Travel Date"
                  : "${travelDate.day}/${travelDate.month}/${travelDate.year}",
            ),
          ),

          const SizedBox(height: 24),

          Text("Travelers", style: Theme.of(context).textTheme.titleMedium),

          const SizedBox(height: 12),

          Row(
            children: [
              IconButton(
                onPressed: travelers > 1
                    ? () {
                        ref.read(travelersProvider.notifier).state--;
                      }
                    : null,
                icon: const Icon(Icons.remove_circle),
              ),

              Text(travelers.toString(), style: const TextStyle(fontSize: 20)),

              IconButton(
                onPressed: travelers < 20
                    ? () {
                        ref.read(travelersProvider.notifier).state++;
                      }
                    : null,
                icon: const Icon(Icons.add_circle),
              ),
            ],
          ),

          const SizedBox(height: 32),

          Card(
            child: ListTile(
              title: const Text("Ticket / Entry Fee"),
              subtitle: const Text("Informational price only"),
              trailing: Text(
                destination.price != null
                    ? "₹${destination.price!.toStringAsFixed(0)}"
                    : "N/A",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Booking Summary",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  const SizedBox(height: 12),

                  Text("Destination: ${destination.title}"),

                  Text(
                    "Date: ${travelDate == null ? 'Not Selected' : '${travelDate.day}/${travelDate.month}/${travelDate.year}'}",
                  ),

                  Text("Travelers: $travelers"),

                  Text(
                    "Ticket / Entry Fee: ${destination.price != null ? "₹${destination.price!.toStringAsFixed(0)}" : "N/A"}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          FilledButton(
            onPressed: isLoading || travelDate == null
                ? null
                : () async {
                    ref.read(bookingLoadingProvider.notifier).state = true;

                    try {
                      final booking = BookingModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        destinationId: destination.id,
                        destinationName: destination.title,
                        destinationLocation: destination.location,
                        destinationImageUrl: destination.imageUrl,
                        destinationLatitude: destination.latitude,
                        destinationLongitude: destination.longitude,
                        userId: FirebaseAuth.instance.currentUser!.uid,
                        travelDate: travelDate,
                        travelers: travelers,
                        status: TripStatus.upcoming,
                        bookingDate: DateTime.now(),
                      );

                      await ref.read(bookingControllerProvider).book(booking);

                      try {
                        await NotificationService.instance.scheduleTripReminder(
                          destination: destination.title,
                          travelDate: travelDate,
                        );
                      } catch (e) {
                        debugPrint("Trip reminder scheduling failed: $e");
                      }

                      // Reset booking form for the next booking.
                      ref.read(travelDateProvider.notifier).state = null;
                      ref.read(travelersProvider.notifier).state = 1;

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("🎉 Trip saved successfully!"),
                        ),
                      );

                      context.go('/booking-success');
                    } finally {
                      ref.read(bookingLoadingProvider.notifier).state = false;
                    }
                  },
            child: isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text("Save Trip"),
          ),
        ],
      ),
    );
  }
}
