import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/saved_trip_model.dart';

class SavedTripService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> saveTrip(SavedTripModel trip) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_trips')
        .doc(trip.id)
        .set(trip.toMap());
  }

  Stream<List<SavedTripModel>> getTrips() {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_trips')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SavedTripModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> deleteTrip(String id) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('saved_trips')
        .doc(id)
        .delete();
  }
}
