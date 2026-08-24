import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../home/data/models/destination_model.dart';
import '../../favorites/data/models/favorite_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  AuthRepository() {
    _googleSignIn.initialize(
      serverClientId:
          '308035912254-nd6vqsm7ir6u0llrjc6enehn43r4llae.apps.googleusercontent.com',
    );
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

    final googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    final user = userCredential.user!;

    final doc = _firestore.collection('users').doc(user.uid);

    if (!(await doc.get()).exists) {
      await doc.set({
        'uid': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return userCredential;
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(name);

    await _firestore.collection('users').doc(credential.user!.uid).set({
      'uid': credential.user!.uid,
      'name': name,
      'email': email,
      'photoUrl': '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  Future<void> resetPassword(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() {
    return _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  Future<void> updateProfile({required String name}) async {
    final user = _auth.currentUser!;

    await user.updateDisplayName(name);

    await _firestore.collection('users').doc(user.uid).update({'name': name});
  }

  Future<void> uploadProfilePhoto(File image) async {
    final user = _auth.currentUser!;

    final ref = _storage.ref().child('profile_photos').child('${user.uid}.jpg');

    await ref.putFile(image);

    final url = await ref.getDownloadURL();

    await user.updatePhotoURL(url);

    await _firestore.collection('users').doc(user.uid).update({
      'photoUrl': url,
    });
  }

  Future<void> addFavorite(DestinationModel destination) async {
    final user = _auth.currentUser!;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(destination.id)
        .set({
          ...destination.toMap(),
          'destinationId': destination.id,
          'addedAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> removeFavorite(String destinationId) async {
    final user = _auth.currentUser!;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(destinationId)
        .delete();
  }

  Stream<List<String>> favoriteIds() {
    final user = _auth.currentUser!;

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  Stream<List<FavoriteModel>> favorites() {
    final user = _auth.currentUser!;

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FavoriteModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
