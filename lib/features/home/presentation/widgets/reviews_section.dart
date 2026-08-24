import 'package:flutter/material.dart';

import '../../data/models/review_model.dart';
import 'review_card.dart';

class ReviewsSection extends StatelessWidget {
  const ReviewsSection({
    super.key,
    required this.reviews,
  });

  final List<ReviewModel> reviews;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const Text("No reviews yet.");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Reviews",
          style: Theme.of(context).textTheme.titleLarge,
        ),

        const SizedBox(height: 16),

        ...reviews.map(
          (review) => ReviewCard(review: review),
        ),
      ],
    );
  }
}