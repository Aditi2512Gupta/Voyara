import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/travel_interest_model.dart';

class TravelInterestService {
  final _firestore = FirebaseFirestore.instance;

  Future<List<TravelInterestModel>> getInterests() async {
    final snapshot =
        await _firestore.collection('travel_interests').get();

    return snapshot.docs
        .map(
          (doc) => TravelInterestModel.fromMap(
            doc.data(),
            doc.id,
          ),
        )
        .toList();
  }
}