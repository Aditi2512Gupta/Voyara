import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/review_model.dart';
import '../../providers/review_controller.dart';

class AddReviewDialog extends ConsumerStatefulWidget {
  const AddReviewDialog({
    super.key,
    required this.destinationId,
    this.existingReview,
  });

  final String destinationId;
  final ReviewModel? existingReview;

  @override
  ConsumerState<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends ConsumerState<AddReviewDialog> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();

  double _rating = 5.0;
  bool _isLoading = false;

  bool get _isEditing => widget.existingReview != null;

  @override
  void initState() {
    super.initState();
    if (widget.existingReview != null) {
      _rating = widget.existingReview!.rating;
      _commentController.text = widget.existingReview!.comment;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit(User user) async {
    if (!_formKey.currentState!.validate()) return;

    if (_rating < 1 || _rating > 5) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a rating between 1 and 5 stars."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userName = user.displayName?.trim().isNotEmpty == true
          ? user.displayName!.trim()
          : (user.email != null && user.email!.contains('@')
                ? user.email!.split('@').first
                : 'Traveler');

      if (_isEditing) {
        await ref
            .read(reviewControllerProvider)
            .updateReview(
              destinationId: widget.destinationId,
              reviewId: widget.existingReview!.id,
              rating: _rating,
              comment: _commentController.text.trim(),
            );
      } else {
        await ref
            .read(reviewControllerProvider)
            .addReview(
              destinationId: widget.destinationId,
              userId: user.uid,
              userName: userName,
              userPhotoUrl: user.photoURL,
              comment: _commentController.text.trim(),
              rating: _rating,
            );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? "Review updated successfully!"
                  : "Review submitted successfully!",
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save review: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return AlertDialog(
        title: const Text("Sign In Required"),
        content: const Text("You must be signed in to write or edit a review."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/login');
            },
            child: const Text("Log In"),
          ),
        ],
      );
    }

    final displayName = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : (user.email != null && user.email!.contains('@')
              ? user.email!.split('@').first
              : 'Traveler');

    return AlertDialog(
      title: Text(_isEditing ? "Edit Review" : "Write Review"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logged-in user information display
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage:
                          user.photoURL != null && user.photoURL!.isNotEmpty
                          ? NetworkImage(user.photoURL!)
                          : null,
                      child: user.photoURL == null || user.photoURL!.isEmpty
                          ? Text(
                              displayName.isNotEmpty
                                  ? displayName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            user.email ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Rating label & Stars
              Center(
                child: Text(
                  "${_rating.toStringAsFixed(1)} / 5.0",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starValue = index + 1;
                  return IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      starValue <= _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 34,
                    ),
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(() {
                              _rating = starValue.toDouble();
                            });
                          },
                  );
                }),
              ),

              Slider(
                value: _rating,
                min: 1,
                max: 5,
                divisions: 8,
                label: _rating.toStringAsFixed(1),
                onChanged: _isLoading
                    ? null
                    : (v) {
                        setState(() {
                          _rating = v;
                        });
                      },
              ),

              const SizedBox(height: 12),

              // Comment input with validation
              TextFormField(
                controller: _commentController,
                maxLines: 4,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: "Your Review",
                  hintText: "Share your experience about this destination...",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter your review.";
                  }
                  if (value.trim().length < 5) {
                    return "Review must be at least 5 characters.";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: _isLoading ? null : () => _submit(user),
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(_isEditing ? "Update Review" : "Submit Review"),
        ),
      ],
    );
  }
}
