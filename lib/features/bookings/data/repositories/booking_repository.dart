import '../models/booking_model.dart';
import '../services/booking_service.dart';

class BookingRepository {
  const BookingRepository({required BookingService service})
    : _service = service;

  final BookingService _service;

  Future<void> createBooking(BookingModel booking) {
    return _service.createBooking(booking);
  }

  Stream<List<BookingModel>> bookings() {
    return _service.bookings();
  }

  Future<void> cancelBooking(String bookingId) {
    return _service.cancelBooking(bookingId);
  }

  Future<void> updateCompletedTrips() {
    return _service.updateCompletedTrips();
  }
}
