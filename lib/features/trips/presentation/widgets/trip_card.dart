import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../home/providers/home_provider.dart';
import '../../../home/data/models/unsplash_image_model.dart';
import '../../../bookings/data/models/booking_model.dart';
import '../../data/models/trip_status.dart';

class TripCard extends ConsumerWidget {
  const TripCard({super.key, required this.trip});

  final BookingModel trip;

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month];
  }

  String getTripSubtitle() {
    final now = DateTime.now();

    if (trip.status == TripStatus.completed) {
      return "Trip Completed";
    }

    if (trip.status == TripStatus.cancelled) {
      return "Trip Cancelled";
    }

    final days = trip.travelDate.difference(now).inDays;

    if (days <= 0) {
      return "Starts Today";
    }

    return "$days day${days == 1 ? '' : 's'} remaining";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color statusColor;

    switch (trip.status) {
      case TripStatus.upcoming:
        statusColor = Colors.green;
        break;
      case TripStatus.completed:
        statusColor = Colors.blue;
        break;
      case TripStatus.cancelled:
        statusColor = Colors.red;
        break;
    }

    final imagesAsync = ref.watch(
      destinationImagesProvider(
        '${trip.destinationName}, ${trip.destinationLocation}',
      ),
    );

    return InkWell(
      onTap: () {
        context.push('/booking-details', extra: trip);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: trip.destinationImageUrl.trim().isNotEmpty
                  ? trip.destinationImageUrl
                  : imagesAsync.maybeWhen(
                      data: (images) =>
                          images.isNotEmpty ? images.first.imageUrl : '',
                      orElse: () => '',
                    ),
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 120,
                height: 120,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
              errorWidget: (_, __, ___) => Container(
                width: 120,
                height: 120,
                color: Colors.grey.shade300,
                child: const Icon(Icons.image),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.destinationName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(trip.destinationLocation),

                    const SizedBox(height: 8),

                    Text("Travelers: ${trip.travelers}"),

                    const SizedBox(height: 4),

                    Text(
                      getTripSubtitle(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    Text(
                      "${trip.travelDate.day} ${_monthName(trip.travelDate.month)}, ${trip.travelDate.year}",
                    ),

                    const SizedBox(height: 10),

                    Chip(
                      avatar: Icon(
                        switch (trip.status) {
                          TripStatus.upcoming => Icons.schedule,
                          TripStatus.completed => Icons.check_circle,
                          TripStatus.cancelled => Icons.cancel,
                        },
                        color: statusColor,
                        size: 18,
                      ),
                      backgroundColor: statusColor.withOpacity(0.15),
                      label: Text(
                        trip.status.name.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
