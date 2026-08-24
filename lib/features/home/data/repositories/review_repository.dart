import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/review_model.dart';

class ReviewRepository {
  ReviewRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Future<List<ReviewModel>> getReviews(String destinationId) async {
    final snapshot = await _firestore
        .collection('destinations')
        .doc(destinationId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ReviewModel.fromMap(doc.data()))
        .toList();
  }

  Future<void> addReview({
    required String destinationId,
    required ReviewModel review,
  }) async {
    await _firestore
        .collection('destinations')
        .doc(destinationId)
        .collection('reviews')
        .add(review.toMap());
  }
}