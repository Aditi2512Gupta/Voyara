import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/review_model.dart';

class ReviewRepository {
  ReviewRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<ReviewModel>> getReviews(String destinationId) {
    return _firestore
        .collection('destinations')
        .doc(destinationId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<List<ReviewModel>> fetchReviews(String destinationId) async {
    final snapshot = await _firestore
        .collection('destinations')
        .doc(destinationId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
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

    await _recalculateDestinationRating(destinationId);
  }

  Future<void> updateReview({
    required String destinationId,
    required String reviewId,
    required double rating,
    required String comment,
  }) async {
    await _firestore
        .collection('destinations')
        .doc(destinationId)
        .collection('reviews')
        .doc(reviewId)
        .update({
          'rating': rating,
          'comment': comment,
          'updatedAt': FieldValue.serverTimestamp(),
        });

    await _recalculateDestinationRating(destinationId);
  }

  Future<void> deleteReview({
    required String destinationId,
    required String reviewId,
  }) async {
    await _firestore
        .collection('destinations')
        .doc(destinationId)
        .collection('reviews')
        .doc(reviewId)
        .delete();

    await _recalculateDestinationRating(destinationId);
  }

  Future<void> _recalculateDestinationRating(String destinationId) async {
    try {
      final snapshot = await _firestore
          .collection('destinations')
          .doc(destinationId)
          .collection('reviews')
          .get();

      final docs = snapshot.docs;
      final int count = docs.length;
      double averageRating = 0.0;

      if (count > 0) {
        final double totalSum = docs.fold<double>(
          0.0,
          (total, doc) =>
              total + ((doc.data()['rating'] as num?)?.toDouble() ?? 0.0),
        );
        averageRating = double.parse((totalSum / count).toStringAsFixed(1));
      }

      await _firestore.collection('destinations').doc(destinationId).set({
        'rating': averageRating,
        'reviewCount': count,
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        // Expected when user is not an admin: destinations root collection is read-only.
        // Client UI calculates and displays live ratings dynamically via the reviews stream.
        return;
      }
      rethrow;
    } catch (_) {
      // Ignore secondary sync errors so that successful review operation is not failed.
    }
  }
}
