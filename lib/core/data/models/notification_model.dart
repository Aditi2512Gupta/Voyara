import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool read;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'createdAt': Timestamp.fromDate(createdAt),
      'read': read,
    };
  }

  factory NotificationModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    final timestamp = map['createdAt'];

    return NotificationModel(
      id: id,
      title: map['title']?.toString() ?? '',
      body: map['body']?.toString() ?? '',
      createdAt: timestamp is Timestamp
          ? timestamp.toDate()
          : DateTime.now(),
      read: map['read'] == true,
    );
  }
}