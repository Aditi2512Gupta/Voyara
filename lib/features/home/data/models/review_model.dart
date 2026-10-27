import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  const ReviewModel({
    this.id = '',
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.rating,
    required this.comment,
    required this.date,
  });

  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final double rating;
  final String comment;
  final DateTime date;

  factory ReviewModel.fromMap(Map<String, dynamic> map, [String id = '']) {
    return ReviewModel(
      id: (map['id'] as String?)?.isNotEmpty == true
          ? (map['id'] as String)
          : id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhotoUrl: map['userPhotoUrl'],
      comment: map['comment'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      date: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      if (userPhotoUrl != null && userPhotoUrl!.isNotEmpty)
        'userPhotoUrl': userPhotoUrl,
      'comment': comment,
      'rating': rating,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  ReviewModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    double? rating,
    String? comment,
    DateTime? date,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      date: date ?? this.date,
    );
  }
}
