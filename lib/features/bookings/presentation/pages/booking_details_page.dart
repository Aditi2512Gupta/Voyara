import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../providers/booking_provider.dart';
import '../../data/models/booking_model.dart';
import '../../../../core/utils/map_launcher.dart';
import '../../../trips/data/models/trip_status.dart';
import '../../../home/presentation/widgets/destination_map.dart';

class BookingDetailsPage extends ConsumerWidget {
  const BookingDetailsPage({super.key, required this.booking});

  final BookingModel booking;

  String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Color statusColor() {
    switch (booking.status) {
      case TripStatus.upcoming:
        return Colors.blue;

      case TripStatus.completed:
        return Colors.green;

      case TripStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trip Details")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CachedNetworkImage(
                        imageUrl: booking.destinationImageUrl,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (_, __, ___) => Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        booking.destinationName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 18),
                          const SizedBox(width: 6),
                          Expanded(child: Text(booking.destinationLocation)),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor().withOpacity(.15),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          booking.status.name.toUpperCase(),
                          style: TextStyle(
                            color: statusColor(),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text("Trip ID", style: Theme.of(context).textTheme.titleMedium),
              Text(booking.id),

              const SizedBox(height: 20),

              Text(
                "Travel Date",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(formatDate(booking.travelDate)),

              const SizedBox(height: 20),

              Text(
                "Saved Date",
                style: Theme.of(context).textTheme.titleMedium,
              ),

              Text(formatDate(booking.bookingDate)),

              const SizedBox(height: 20),

              Text("Travelers", style: Theme.of(context).textTheme.titleMedium),
              Text("${booking.travelers}"),

              const SizedBox(height: 20),

              Text(
                "Coordinates",
                style: Theme.of(context).textTheme.titleMedium,
              ),

              SelectableText(
                "${booking.destinationLatitude.toStringAsFixed(5)}, "
                "${booking.destinationLongitude.toStringAsFixed(5)}",
              ),

              const SizedBox(height: 16),

              DestinationMap(
                latitude: booking.destinationLatitude,
                longitude: booking.destinationLongitude,
              ),

              const SizedBox(height: 16),

              FilledButton.icon(
                onPressed: () {
                  MapLauncher.openGoogleMaps(
                    latitude: booking.destinationLatitude,
                    longitude: booking.destinationLongitude,
                  );
                },
                icon: const Icon(Icons.map),
                label: const Text("Open in Google Maps"),
              ),

              const SizedBox(height: 24),

              if (booking.canCancel)
                FilledButton.icon(
                  onPressed: () async {
                    final shouldCancel = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Cancel Trip"),
                        content: const Text(
                          "Are you sure you want to cancel this trip?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("No"),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Yes"),
                          ),
                        ],
                      ),
                    );

                    if (shouldCancel != true) return;

                    await ref
                        .read(bookingControllerProvider)
                        .cancelBooking(booking.id);

                    if (context.mounted) {
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Trip cancelled successfully"),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.cancel),
                  label: const Text("Cancel Trip"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
