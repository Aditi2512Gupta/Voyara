import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'review_provider.dart';
import '../data/models/review_model.dart';

final reviewControllerProvider = Provider((ref) => ReviewController(ref));

class ReviewController {
  ReviewController(this.ref);

  final Ref ref;

  Future<void> addReview({
    required String destinationId,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required String comment,
    required double rating,
  }) async {
    await ref
        .read(reviewRepositoryProvider)
        .addReview(
          destinationId: destinationId,
          review: ReviewModel(
            userId: userId,
            userName: userName,
            userPhotoUrl: userPhotoUrl,
            comment: comment,
            rating: rating,
            date: DateTime.now(),
          ),
        );
  }

  Future<void> updateReview({
    required String destinationId,
    required String reviewId,
    required double rating,
    required String comment,
  }) async {
    await ref
        .read(reviewRepositoryProvider)
        .updateReview(
          destinationId: destinationId,
          reviewId: reviewId,
          rating: rating,
          comment: comment,
        );
  }

  Future<void> deleteReview({
    required String destinationId,
    required String reviewId,
  }) async {
    await ref
        .read(reviewRepositoryProvider)
        .deleteReview(destinationId: destinationId, reviewId: reviewId);
  }
}
