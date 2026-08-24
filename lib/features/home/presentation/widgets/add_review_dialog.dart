import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/review_controller.dart';

class AddReviewDialog extends ConsumerStatefulWidget {
  const AddReviewDialog({
    super.key,
    required this.destinationId,
  });

  final String destinationId;

  @override
  ConsumerState<AddReviewDialog> createState() =>
      _AddReviewDialogState();
}

class _AddReviewDialogState
    extends ConsumerState<AddReviewDialog> {

  final _nameController = TextEditingController();
  final _commentController = TextEditingController();

  double rating = 5;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Write Review"),

      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Your Name",
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Review",
              ),
            ),

            const SizedBox(height: 16),

            Slider(
              value: rating,
              min: 1,
              max: 5,
              divisions: 4,
              label: rating.toString(),
              onChanged: (v) {
                setState(() {
                  rating = v;
                });
              },
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),

        FilledButton(
          onPressed: () async {
            await ref
                .read(reviewControllerProvider)
                .addReview(
                  destinationId: widget.destinationId,
                  userName: _nameController.text,
                  comment: _commentController.text,
                  rating: rating,
                );

            if (mounted) {
              Navigator.pop(context);
            }
          },
          child: const Text("Submit"),
        ),
      ],
    );
  }
}