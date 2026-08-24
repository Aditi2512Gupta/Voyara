import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/booking_model.dart';
import '../data/repositories/booking_repository.dart';
import '../data/services/booking_service.dart';

final bookingServiceProvider = Provider<BookingService>(
  (ref) => BookingService(),
);

final bookingRepositoryProvider = Provider<BookingRepository>(
  (ref) => BookingRepository(service: ref.read(bookingServiceProvider)),
);

final bookingsProvider = StreamProvider<List<BookingModel>>((ref) {
  return ref.read(bookingRepositoryProvider).bookings();
});

final bookingControllerProvider = Provider<BookingController>(
  (ref) => BookingController(repository: ref.read(bookingRepositoryProvider)),
);

class BookingController {
  BookingController({required BookingRepository repository})
    : _repository = repository;

  final BookingRepository _repository;

  Future<void> book(BookingModel booking) {
    return _repository.createBooking(booking);
  }

  Future<void> cancelBooking(String bookingId) {
    return _repository.cancelBooking(bookingId);
  }

  Future<void> updateCompletedTrips() {
    return _repository.updateCompletedTrips();
  }
}
