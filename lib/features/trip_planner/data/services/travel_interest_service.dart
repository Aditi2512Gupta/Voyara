import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/travel_interest_model.dart';

class TravelInterestService {
  TravelInterestService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _customFirestore = firestore,
        _customAuth = auth;

  final FirebaseFirestore? _customFirestore;
  final FirebaseAuth? _customAuth;

  FirebaseFirestore get _firestore =>
      _customFirestore ?? FirebaseFirestore.instance;
  FirebaseAuth get _auth => _customAuth ?? FirebaseAuth.instance;

  static const List<String> defaultInterests = [
    'Adventure',
    'Beach',
    'Culture',
    'Food & Dining',
    'Heritage',
    'Nature',
    'Nightlife',
    'Relaxation',
    'Shopping',
    'Sightseeing',
    'Wildlife',
    'Photography',
    'Trekking',
    'Spiritual',
  ];

  Future<List<TravelInterestModel>> getInterests() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final snapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('travel_interests')
            .get();

        if (snapshot.docs.isNotEmpty) {
          final list = snapshot.docs
              .map(
                (doc) => TravelInterestModel.fromMap(
                  doc.data(),
                  doc.id,
                ),
              )
              .where((item) => item.name.trim().isNotEmpty)
              .toList();

          if (list.isNotEmpty) {
            return list;
          }
        }
      }
    } catch (_) {
      // In case of any Firestore read issues, fallback to default interests
    }

    return defaultInterests
        .map(
          (name) => TravelInterestModel(
            id: name.toLowerCase().replaceAll(RegExp(r'\s+'), '_'),
            name: name,
          ),
        )
        .toList();
  }

  Future<void> saveInterest(String name) async {
    try {
      final user = _auth.currentUser;
      if (user == null || name.trim().isEmpty) return;

      final trimmed = name.trim();
      final id = trimmed.toLowerCase().replaceAll(RegExp(r'\s+'), '_');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('travel_interests')
          .doc(id)
          .set({'name': trimmed}, SetOptions(merge: true));
    } catch (_) {
      // Ignore errors when saving interest
    }
  }
}