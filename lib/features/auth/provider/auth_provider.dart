import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Live stream of the current Firebase user (null = signed out).
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

/// UI state for auth actions (login/register/reset), separate from the
/// underlying auth stream so screens can show spinners/errors cleanly.
class AuthState {
  final bool isLoading;
  final String? error;

  const AuthState({this.isLoading = false, this.error});
}

/// Riverpod 3.0 Notifier (manual, non-code-gen). `build()` replaces the
/// old constructor + super(initialState) pattern; dependencies are read
/// via `ref` instead of being passed in.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<bool> login(String email, String password) async {
    state = const AuthState(isLoading: true);
    try {
      await _repository.signInWithEmail(email: email, password: password);
      state = const AuthState(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = AuthState(isLoading: false, error: e.message ?? 'Login failed');
      return false;
    } catch (e) {
      state = AuthState(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    state = const AuthState(isLoading: true);
    try {
      await _repository.registerWithEmail(email: email, password: password);
      state = const AuthState(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = AuthState(isLoading: false, error: e.message ?? 'Registration failed');
      return false;
    } catch (e) {
      state = AuthState(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    state = const AuthState(isLoading: true);
    try {
      await _repository.sendPasswordResetEmail(email);
      state = const AuthState(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = AuthState(isLoading: false, error: e.message ?? 'Failed to send reset email');
      return false;
    }
  }

  void clearError() {
    state = AuthState(isLoading: state.isLoading, error: null);
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);