import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  const ReviewModel({
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  final String userName;
  final double rating;
  final String comment;
  final DateTime date;

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      userName: map['userName'] ?? '',
      comment: map['comment'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      date: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'comment': comment,
      'rating': rating,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
