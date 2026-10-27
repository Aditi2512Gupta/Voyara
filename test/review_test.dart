import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voyara/features/home/data/models/destination_model.dart';
import 'package:voyara/features/home/data/models/review_model.dart';

void main() {
  group('ReviewModel Tests', () {
    test('ReviewModel serialization and deserialization with ID and userId', () {
      final now = DateTime.now();
      final review = ReviewModel(
        id: 'rev_123',
        userId: 'user_456',
        userName: 'Alice Smith',
        userPhotoUrl: 'https://example.com/alice.jpg',
        rating: 4.5,
        comment: 'Stunning place to visit!',
        date: now,
      );

      final map = review.toMap();
      expect(map['userId'], 'user_456');
      expect(map['userName'], 'Alice Smith');
      expect(map['userPhotoUrl'], 'https://example.com/alice.jpg');
      expect(map['rating'], 4.5);
      expect(map['comment'], 'Stunning place to visit!');
      expect(map['createdAt'], isA<FieldValue>());

      final fromMapData = {
        'id': 'rev_123',
        'userId': 'user_456',
        'userName': 'Alice Smith',
        'userPhotoUrl': 'https://example.com/alice.jpg',
        'rating': 4.5,
        'comment': 'Stunning place to visit!',
        'createdAt': Timestamp.fromDate(now),
      };

      final parsed = ReviewModel.fromMap(fromMapData, 'rev_123');
      expect(parsed.id, 'rev_123');
      expect(parsed.userId, 'user_456');
      expect(parsed.userName, 'Alice Smith');
      expect(parsed.userPhotoUrl, 'https://example.com/alice.jpg');
      expect(parsed.rating, 4.5);
      expect(parsed.comment, 'Stunning place to visit!');
    });

    test('ReviewModel copyWith works correctly', () {
      final original = ReviewModel(
        id: '1',
        userId: 'u1',
        userName: 'Bob',
        rating: 3.0,
        comment: 'Nice',
        date: DateTime.now(),
      );

      final updated = original.copyWith(
        rating: 5.0,
        comment: 'Awesome!',
      );

      expect(updated.id, '1');
      expect(updated.userId, 'u1');
      expect(updated.userName, 'Bob');
      expect(updated.rating, 5.0);
      expect(updated.comment, 'Awesome!');
    });
  });

  group('DestinationModel Tests with reviewCount', () {
    test('DestinationModel correctly reads and writes reviewCount and rating', () {
      final map = {
        'destinationId': 'dest_999',
        'title': 'Taj Mahal',
        'location': 'Agra, India',
        'imageUrl': 'https://example.com/taj.jpg',
        'rating': 4.8,
        'reviewCount': 125,
        'price': 50.0,
        'description': 'Iconic monument',
        'categories': ['Historical'],
        'includes': ['Guide'],
        'latitude': 27.1751,
        'longitude': 78.0421,
      };

      final destination = DestinationModel.fromMap(map, 'dest_999');
      expect(destination.id, 'dest_999');
      expect(destination.rating, 4.8);
      expect(destination.reviewCount, 125);

      final serialized = destination.toMap();
      expect(serialized['rating'], 4.8);
      expect(serialized['reviewCount'], 125);
    });
  });
}
