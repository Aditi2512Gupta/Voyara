import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../home/providers/home_provider.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color statusColor;
    Color statusBgColor;

    switch (trip.status) {
      case TripStatus.upcoming:
        statusColor = const Color(0xFF0E7A60);
        statusBgColor = AppColors.mintLight;
        break;
      case TripStatus.completed:
        statusColor = AppColors.primary;
        statusBgColor = AppColors.secondaryLight;
        break;
      case TripStatus.cancelled:
        statusColor = AppColors.error;
        statusBgColor = AppColors.errorLight;
        break;
    }

    final imagesAsync = ref.watch(
      destinationImagesProvider(
        '${trip.destinationName}, ${trip.destinationLocation}',
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            context.push('/booking-details', extra: trip);
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Thumbnail Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 95,
                    height: 95,
                    child: CachedNetworkImage(
                      imageUrl: trip.destinationImageUrl.trim().isNotEmpty
                          ? trip.destinationImageUrl
                          : imagesAsync.maybeWhen(
                              data: (images) => images.isNotEmpty
                                  ? images.first.imageUrl
                                  : '',
                              orElse: () => '',
                            ),
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        color: isDark
                            ? AppColors.inputDark
                            : AppColors.inputLight,
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      errorWidget: (_, _, _) => Container(
                        color: isDark
                            ? AppColors.inputDark
                            : AppColors.inputLight,
                        child: Icon(
                          Icons.travel_explore,
                          color: isDark
                              ? AppColors.secondary
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // Trip Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Destination & Status Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              trip.destinationName,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              trip.status.name[0].toUpperCase() +
                                  trip.status.name.substring(1),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 3),

                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: isDark
                                ? AppColors.secondary
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              trip.destinationLocation,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Travel Date & Travelers
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: AppColors.textTertiaryLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${trip.travelDate.day} ${_monthName(trip.travelDate.month)} ${trip.travelDate.year}",
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            " • ${trip.travelers} Traveler${trip.travelers == 1 ? '' : 's'}",
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Subtitle / Countdown (maintains text expected by tests)
                      Text(
                        getTripSubtitle(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
