import 'package:firebase_auth/firebase_auth.dart';

/// Turns Firebase Auth errors into short, user-facing messages.
String friendlyAuthError(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for this email. Try logging in instead.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No internet connection. Check your network and try again.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled in the Firebase console.';
      case 'account-exists-with-different-credential':
        return 'This email is already registered with a different sign-in method.';
    }
    return error.message ?? 'Something went wrong. Please try again.';
  }
  return 'Something went wrong. Please try again.';
}