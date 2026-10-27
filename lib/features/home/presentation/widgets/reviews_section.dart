import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/review_model.dart';
import '../../providers/review_controller.dart';
import 'add_review_dialog.dart';
import 'review_card.dart';

class ReviewsSection extends ConsumerWidget {
  const ReviewsSection({
    super.key,
    required this.destinationId,
    required this.reviews,
    this.currentUserId,
  });

  final String destinationId;
  final List<ReviewModel> reviews;
  final String? currentUserId;

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    ReviewModel review,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Review"),
        content: const Text(
          "Are you sure you want to delete your review? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Deleting review..."),
          duration: Duration(seconds: 1),
        ),
      );

      await ref.read(reviewControllerProvider).deleteReview(
            destinationId: destinationId,
            reviewId: review.id,
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Review deleted successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete review: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (reviews.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Reviews (0)",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            "No reviews yet. Be the first to share your experience!",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      );
    }

    final double avgRating = reviews.fold<double>(0.0, (s, r) => s + r.rating) /
        reviews.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Reviews (${reviews.length})",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              avgRating.toStringAsFixed(1),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        ...reviews.map(
          (review) {
            final isOwner = currentUserId != null &&
                currentUserId!.isNotEmpty &&
                review.userId == currentUserId;

            return ReviewCard(
              review: review,
              onEdit: isOwner
                  ? () => showDialog(
                        context: context,
                        builder: (_) => AddReviewDialog(
                          destinationId: destinationId,
                          existingReview: review,
                        ),
                      )
                  : null,
              onDelete: isOwner
                  ? () => _handleDelete(context, ref, review)
                  : null,
            );
          },
        ),
      ],
    );
  }
}