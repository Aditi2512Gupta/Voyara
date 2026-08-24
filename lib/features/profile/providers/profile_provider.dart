import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/user_profile_model.dart';

final profileProvider = FutureProvider<UserProfileModel>((ref) async {
  final user = FirebaseAuth.instance.currentUser!;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  final data = doc.data()!;

  return UserProfileModel(
    name: data['name'] ?? '',
    email: data['email'] ?? '',
    photoUrl: data['photoUrl'] ?? '',
    phone: data['phone'] ?? '',
    joinedOn: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
});
