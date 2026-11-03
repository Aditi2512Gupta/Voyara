import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/services/notification_service.dart';
import '../../../auth/providers/auth_provider.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoading = ref.watch(bookingLoadingProvider);
    final travelDate = ref.watch(travelDateProvider);
    final travelers = ref.watch(travelersProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldDark
          : AppColors.scaffoldLight,
      appBar: AppBar(
        title: const Text(
          "Book Trip",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ResponsiveContentWrapper(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Destination Title Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.flight_takeoff_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          destination.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          destination.location,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Date Selection Button
            FilledButton.icon(
              onPressed: () async {
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final initial =
                    travelDate != null && !travelDate.isBefore(today)
                    ? travelDate
                    : today;

                final selected = await showDatePicker(
                  context: context,
                  firstDate: today,
                  lastDate: DateTime(2035),
                  initialDate: initial,
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
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: isDark ? AppColors.cardDark : Colors.white,
                foregroundColor: isDark
                    ? Colors.white
                    : AppColors.textPrimaryLight,
                side: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Travelers Stepper Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Travelers",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
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
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        travelers.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: travelers < 20
                            ? () {
                                ref.read(travelersProvider.notifier).state++;
                              }
                            : null,
                        icon: const Icon(Icons.add_circle),
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Ticket Fee Card
            Card(
              child: ListTile(
                title: const Text("Ticket / Entry Fee"),
                subtitle: const Text("Informational price only"),
                trailing: Text(
                  destination.price != null
                      ? "₹${destination.price!.toStringAsFixed(0)}"
                      : "N/A",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Booking Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Booking Summary",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text("Destination: ${destination.title}"),
                    const SizedBox(height: 4),
                    Text(
                      "Date: ${travelDate == null ? 'Not Selected' : '${travelDate.day}/${travelDate.month}/${travelDate.year}'}",
                    ),
                    const SizedBox(height: 4),
                    Text("Travelers: $travelers"),
                    const SizedBox(height: 4),
                    Text(
                      "Ticket / Entry Fee: ${destination.price != null ? "₹${destination.price!.toStringAsFixed(0)}" : "N/A"}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Save Trip Button (matches test finder)
            FilledButton(
              onPressed: isLoading || travelDate == null
                  ? null
                  : () async {
                      final currentUser = ref.read(currentUserProvider);
                      if (currentUser == null) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              "Please log in to save your trip",
                            ),
                            action: SnackBarAction(
                              label: "Log In",
                              onPressed: () => context.push('/login'),
                            ),
                          ),
                        );
                        return;
                      }

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
                          userId: currentUser.uid,
                          travelDate: travelDate,
                          travelers: travelers,
                          status: TripStatus.upcoming,
                          bookingDate: DateTime.now(),
                        );

                        await ref.read(bookingControllerProvider).book(booking);

                        try {
                          await NotificationService.instance
                              .scheduleTripReminder(
                                destination: destination.title,
                                travelDate: travelDate,
                                tripId: booking.id,
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
                      } catch (e) {
                        debugPrint("Booking creation failed: $e");
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Failed to save trip: ${e.toString().replaceFirst(RegExp(r'^Exception: '), '')}",
                              ),
                              backgroundColor: Colors.red.shade700,
                            ),
                          );
                        }
                      } finally {
                        ref.read(bookingLoadingProvider.notifier).state = false;
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      "Save Trip",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
