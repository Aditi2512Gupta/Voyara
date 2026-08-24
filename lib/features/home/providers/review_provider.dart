import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/models/review_model.dart';
import '../data/repositories/review_repository.dart';

final reviewRepositoryProvider = Provider(
  (ref) => ReviewRepository(FirebaseFirestore.instance),
);

final reviewsProvider =
    FutureProvider.family<List<ReviewModel>, String>((ref, destinationId) {
  return ref
      .read(reviewRepositoryProvider)
      .getReviews(destinationId);
});