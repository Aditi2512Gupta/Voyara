import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/models/user_profile_model.dart';

DateTime _safeCreationTime(User user) {
  try {
    return user.metadata.creationTime ?? DateTime.now();
  } catch (_) {
    return DateTime.now();
  }
}

final profileProvider = FutureProvider<UserProfileModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return null;
  }

  try {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data();

    if (data == null) {
      return UserProfileModel(
        name: user.displayName?.isNotEmpty == true
            ? user.displayName!
            : (user.email?.split('@').first ?? 'Traveler'),
        email: user.email ?? '',
        photoUrl: user.photoURL ?? '',
        phone: user.phoneNumber ?? '',
        joinedOn: _safeCreationTime(user),
      );
    }

    return UserProfileModel(
      name: (data['name'] as String?)?.isNotEmpty == true
          ? data['name'] as String
          : (user.displayName ?? 'Traveler'),
      email: (data['email'] as String?)?.isNotEmpty == true
          ? data['email'] as String
          : (user.email ?? ''),
      photoUrl: (data['photoUrl'] as String?)?.isNotEmpty == true
          ? data['photoUrl'] as String
          : (user.photoURL ?? ''),
      phone: (data['phone'] as String?)?.isNotEmpty == true
          ? data['phone'] as String
          : (user.phoneNumber ?? ''),
      joinedOn: (data['createdAt'] as Timestamp?)?.toDate() ??
          _safeCreationTime(user),
    );
  } catch (_) {
    return UserProfileModel(
      name: user.displayName?.isNotEmpty == true
          ? user.displayName!
          : (user.email?.split('@').first ?? 'Traveler'),
      email: user.email ?? '',
      photoUrl: user.photoURL ?? '',
      phone: user.phoneNumber ?? '',
      joinedOn: _safeCreationTime(user),
    );
  }
});
