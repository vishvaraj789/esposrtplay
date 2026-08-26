import 'package:cloud_firestore/cloud_firestore.dart';

/// Handles all reads/writes to the `users` collection in Firestore.
/// Each document is keyed by the Firebase Auth UID, so there's a
/// 1:1 mapping between an authenticated user and their profile data.
class UserService {
  UserService._();
  static final UserService instance = UserService._();

  final CollectionReference<Map<String, dynamic>> _usersRef =
  FirebaseFirestore.instance.collection('users');

  /// Called right after FirebaseAuth.createUserWithEmailAndPassword succeeds.
  /// Saves the extra profile fields your form collects that Firebase Auth
  /// itself doesn't store (UID game ID, nickname, role, etc.).
  ///
  /// Throws a [StateError] if a profile already exists for this uid, so a
  /// user can never accidentally submit UserForm twice and overwrite their
  /// original data.
  Future<void> createUserProfile({
    required String uid,
    required String fullName,
    required String email,
    required String freeFireUid,
    required String nickname,
    required String role,
    String? inGameRole,
  }) async {
    final docRef = _usersRef.doc(uid);

    // Use a transaction so the existence check and the write happen
    // atomically — this closes the race where two rapid submits (e.g.
    // double-tapping the button) could both pass an existence check
    // before either one has written.
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (snapshot.exists) {
        throw StateError('A profile already exists for this account.');
      }

      transaction.set(docRef, {
        'fullName': fullName,
        'email': email,
        'freeFireUid': freeFireUid,
        'nickname': nickname,
        'role': role,
        'inGameRole': inGameRole,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Fetches a single user's profile document once (e.g. for Profile screen).
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final snapshot = await _usersRef.doc(uid).get();
    return snapshot.data();
  }

  /// Returns true if this user already completed UserForm (i.e. a Firestore
  /// profile document exists for them). Used by AuthGate to decide whether
  /// to show UserForm or skip straight into the main app.
  Future<bool> hasProfile(String uid) async {
    final snapshot = await _usersRef.doc(uid).get();
    return snapshot.exists;
  }

  /// Streams a single user's profile so UI updates live if the data changes
  /// (e.g. nickname edited from another device).
  Stream<Map<String, dynamic>?> watchUserProfile(String uid) {
    return _usersRef.doc(uid).snapshots().map((snapshot) => snapshot.data());
  }

  /// Updates specific fields without overwriting the whole document.
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _usersRef.doc(uid).update(data);
  }

  /// Streams all users with a given role (e.g. all "Organizer"s),
  /// useful for admin screens or team invites.
  Stream<List<Map<String, dynamic>>> watchUsersByRole(String role) {
    return _usersRef
        .where('role', isEqualTo: role)
        .snapshots()
        .map((query) => query.docs.map((doc) => doc.data()).toList());
  }
}