import 'package:firebase_auth/firebase_auth.dart';

class StartupController {
  const StartupController();

  Future<bool> isLoggedIn() async {
    await Future.delayed(const Duration(seconds: 2));

    return FirebaseAuth.instance.currentUser != null;
  }
}