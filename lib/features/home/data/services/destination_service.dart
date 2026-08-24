import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/destination_model.dart';

class DestinationService {
  DestinationService();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<List<DestinationModel>> fetchDestinations() async {
    final snapshot = await _firestore
        .collection('destinations')
        .get();

    return snapshot.docs
        .map(
          (doc) => DestinationModel.fromMap(
            doc.data(),
            doc.id,
          ),
        )
        .toList();
  }

  Future<DestinationModel?> getDestination(
    String id,
  ) async {
    final doc = await _firestore
        .collection('destinations')
        .doc(id)
        .get();

    if (!doc.exists) return null;

    return DestinationModel.fromMap(
      doc.data()!,
      doc.id,
    );
  }
}