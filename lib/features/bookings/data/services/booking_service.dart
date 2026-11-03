import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/data/repositories/notification_repository.dart';
import '../../../../core/services/notification_service.dart';
import '../models/booking_model.dart';

class BookingService {
  BookingService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    NotificationRepository? notificationRepository,
  }) : _customFirestore = firestore,
       _customAuth = auth,
       _customNotificationRepository = notificationRepository;

  final FirebaseFirestore? _customFirestore;
  final FirebaseAuth? _customAuth;
  final NotificationRepository? _customNotificationRepository;

  FirebaseFirestore get _firestore =>
      _customFirestore ?? FirebaseFirestore.instance;

  FirebaseAuth? get _auth {
    if (_customAuth != null) return _customAuth;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  NotificationRepository get _notificationRepository =>
      _customNotificationRepository ?? NotificationRepository();

  Future<void> createBooking(BookingModel booking) async {
    final user = _auth?.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to create a booking');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookings')
        .doc(booking.id)
        .set(booking.toMap());

    await _notificationRepository.addNotification(
      title: 'Trip Saved 🎉',
      body:
          'Your trip to ${booking.destinationName} has been saved successfully.',
    );
  }

  Stream<List<BookingModel>> bookings() {
    final user = _auth?.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookings')
        .orderBy('travelDate', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future cancelBooking(String bookingId) async {
    final user = _auth?.currentUser;
    if (user == null) {
      throw Exception('User must be logged in to cancel a booking');
    }

    final bookingRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookings')
        .doc(bookingId);

    final bookingSnapshot = await bookingRef.get();

    if (!bookingSnapshot.exists) {
      throw Exception('Booking not found');
    }

    final booking = BookingModel.fromMap(
      bookingSnapshot.data()!,
      bookingSnapshot.id,
    );

    await bookingRef.update({'status': 'cancelled'});

    try {
      await NotificationService.instance.cancelTripReminder(bookingId);
    } catch (_) {}

    await _notificationRepository.addNotification(
      title: 'Trip Cancelled',
      body: 'Your trip to ${booking.destinationName} has been cancelled.',
    );
  }

  Future<void> updateCompletedTrips() async {
    final user = _auth?.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookings')
        .where('status', isEqualTo: 'upcoming')
        .get();

    final now = DateTime.now();

    for (final doc in snapshot.docs) {
      final booking = BookingModel.fromMap(doc.data(), doc.id);

      if (booking.travelDate.isBefore(now)) {
        await doc.reference.update({'status': 'completed'});
      }
    }
  }
}
