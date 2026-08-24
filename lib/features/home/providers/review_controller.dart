import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'review_provider.dart';
import '../data/models/review_model.dart';

final reviewControllerProvider = Provider((ref) => ReviewController(ref));

class ReviewController {
  ReviewController(this.ref);

  final Ref ref;

  Future<void> addReview({
    required String destinationId,
    required String userName,
    required String comment,
    required double rating,
  }) async {
    await ref
        .read(reviewRepositoryProvider)
        .addReview(
          destinationId: destinationId,
          review: ReviewModel(
            userName: userName,
            comment: comment,
            rating: rating,
            date: DateTime.now(),
          ),
        );

    ref.invalidate(reviewsProvider(destinationId));
  }
}
