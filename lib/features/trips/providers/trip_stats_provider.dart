import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../bookings/providers/booking_provider.dart';
import '../../bookings/data/models/booking_model.dart';
import '../data/models/trip_status.dart';

class TripStats {
  final int upcoming;
  final int completed;
  final int cancelled;

  const TripStats({
    required this.upcoming,
    required this.completed,
    required this.cancelled,
  });
}

final tripStatsProvider = Provider<AsyncValue<TripStats>>((ref) {
  final bookings = ref.watch(bookingsProvider);

  return bookings.whenData((list) {
    int upcoming = 0;
    int completed = 0;
    int cancelled = 0;

    for (final BookingModel booking in list) {
      switch (booking.status) {
        case TripStatus.upcoming:
          upcoming++;
          break;

        case TripStatus.completed:
          completed++;
          break;

        case TripStatus.cancelled:
          cancelled++;
          break;
      }
    }

    return TripStats(
      upcoming: upcoming,
      completed: completed,
      cancelled: cancelled,
    );
  });
});