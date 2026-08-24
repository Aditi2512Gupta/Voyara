import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthErrorMapper {
  static String message(Object error) {
    if (error is! FirebaseAuthException) {
      return "Something went wrong. Please try again.";
    }

    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'invalid-credential':
        return 'Invalid email or password.';

      case 'user-not-found':
        return 'No account found with this email.';

      case 'wrong-password':
        return 'Incorrect password.';

      case 'email-already-in-use':
        return 'An account already exists with this email.';

      case 'weak-password':
        return 'Password must be at least 6 characters long.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'network-request-failed':
        return 'No internet connection. Please try again.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';

      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';

      default:
        return error.message ?? 'Authentication failed.';
    }
  }
}