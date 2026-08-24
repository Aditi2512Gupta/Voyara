import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/data/repositories/notification_repository.dart';
import '../models/booking_model.dart';

class BookingService {
  BookingService();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _notificationRepository = NotificationRepository();

  Future<void> createBooking(BookingModel booking) async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
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
    return _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
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
    final bookingRef = _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
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

    await _notificationRepository.addNotification(
      title: 'Trip Cancelled',
      body: 'Your trip to ${booking.destinationName} has been cancelled.',
    );
  }

  Future<void> updateCompletedTrips() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
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
