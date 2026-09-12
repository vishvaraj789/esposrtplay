import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/user_service.dart';
import '../../auth/provider/auth_provider.dart';

// --- Data models ---

class UserProfile {
  final String uid;
  final String fullName;
  final String email;
  final String freeFireUid;
  final String nickname;
  final String? role;
  final String? inGameRole;
  final num walletBalance;
  final String? photoUrl;
  final int matches;
  final int wins;
  final int rank;

  const UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.freeFireUid,
    required this.nickname,
    this.role,
    this.inGameRole,
    this.walletBalance = 0,
    this.photoUrl,
    this.matches = 0,
    this.wins = 0,
    this.rank = 0,
  });

  double get winRate => matches == 0 ? 0 : wins / matches;

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      freeFireUid: data['freeFireUid'] ?? '',
      nickname: data['nickname'] ?? '',
      role: data['role'],
      inGameRole: data['inGameRole'],
      walletBalance: data['walletBalance'] ?? 0,
      photoUrl: data['photoUrl'],
      matches: data['matches'] ?? 0,
      wins: data['wins'] ?? 0,
      rank: data['rank'] ?? 0,
    );
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName; // maps to an IconData in achievement_card.dart
  final bool unlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    this.unlocked = false,
    this.unlockedAt,
  });

  factory Achievement.fromFirestore(String id, Map<String, dynamic> data) {
    return Achievement(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      iconName: data['iconName'] ?? 'emoji_events',
      unlocked: data['unlocked'] ?? false,
      unlockedAt: (data['unlockedAt'] as Timestamp?)?.toDate(),
    );
  }
}

// --- Providers ---

/// Streams the signed-in user's profile, or null if not logged in / no
/// profile doc yet. Depends on authStateProvider so it updates on login/logout.
final currentUserProfileProvider = StreamProvider<UserProfile?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return UserService.instance
          .watchUserProfile(user.uid)
          .map((data) => data == null ? null : UserProfile.fromMap(user.uid, data));
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

final achievementsProvider = StreamProvider.family<List<Achievement>, String>((ref, uid) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('achievements')
      .snapshots()
      .map((snap) => snap.docs.map((d) => Achievement.fromFirestore(d.id, d.data())).toList());
});

// --- Edit-profile action ---

class EditProfileState {
  final bool isSaving;
  final String? error;
  final bool success;

  const EditProfileState({this.isSaving = false, this.error, this.success = false});
}

class EditProfileController extends Notifier<EditProfileState> {
  @override
  EditProfileState build() => const EditProfileState();

  Future<void> save({
    required String uid,
    required String fullName,
    required String nickname,
    required String freeFireUid,
    String? inGameRole,
    String? photoUrl,
  }) async {
    state = const EditProfileState(isSaving: true);
    try {
      await UserService.instance.updateUserProfile(uid, {
        'fullName': fullName,
        'nickname': nickname,
        'freeFireUid': freeFireUid,
        'inGameRole': inGameRole,
        if (photoUrl != null) 'photoUrl': photoUrl,
      });
      state = const EditProfileState(success: true);
    } catch (e) {
      state = EditProfileState(error: e.toString());
    }
  }
}

final editProfileControllerProvider =
NotifierProvider<EditProfileController, EditProfileState>(EditProfileController.new);