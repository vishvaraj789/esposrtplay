import 'package:cloud_firestore/cloud_firestore.dart';

enum PlayerStatus { active, suspended }

PlayerStatus _statusFromString(String? s) =>
    PlayerStatus.values.firstWhere((e) => e.name == s, orElse: () => PlayerStatus.active);

class AdminPlayer {
  final String uid;
  final String nickname;
  final String fullName;
  final String email;
  final String? phone;
  final String freeFireUid;
  final String? photoUrl;
  final int rank;
  final bool verified;
  final PlayerStatus status;
  final DateTime joinedAt;

  const AdminPlayer({
    required this.uid,
    required this.nickname,
    required this.fullName,
    required this.email,
    this.phone,
    required this.freeFireUid,
    this.photoUrl,
    this.rank = 0,
    this.verified = false,
    this.status = PlayerStatus.active,
    required this.joinedAt,
  });

  factory AdminPlayer.fromFirestore(String uid, Map<String, dynamic> data) {
    return AdminPlayer(
      uid: uid,
      nickname: data['nickname'] ?? '',
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      freeFireUid: data['freeFireUid'] ?? '',
      photoUrl: data['photoUrl'],
      rank: data['rank'] ?? 0,
      verified: data['verified'] ?? false, // defaults false for pre-existing accounts
      status: _statusFromString(data['status']), // defaults active if absent
      joinedAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// Extra detail only loaded on the player-details screen (team + tournament
/// count), since it requires extra queries beyond the base user document.
class PlayerParticipation {
  final String? teamId;
  final String? teamName;
  final int tournamentCount;

  const PlayerParticipation({this.teamId, this.teamName, this.tournamentCount = 0});
}