import 'package:cloud_firestore/cloud_firestore.dart';

enum TeamStatus { active, suspended }

TeamStatus _statusFromString(String? s) =>
    TeamStatus.values.firstWhere((e) => e.name == s, orElse: () => TeamStatus.active);

/// A team as the admin panel sees it. `verified` and `status` are admin-only
/// fields; older team documents without them count as unverified + active.
class AdminTeam {
  final String id;
  final String name;
  final String tag;
  final String? logoUrl;
  final String captainUid;
  final List<String> memberUids;
  final int maxMembers;
  final bool verified;
  final TeamStatus status;
  final DateTime createdAt;

  const AdminTeam({
    required this.id,
    required this.name,
    required this.tag,
    this.logoUrl,
    required this.captainUid,
    required this.memberUids,
    this.maxMembers = 4,
    this.verified = false,
    this.status = TeamStatus.active,
    required this.createdAt,
  });

  bool get isSuspended => status == TeamStatus.suspended;

  factory AdminTeam.fromFirestore(String id, Map<String, dynamic> data) {
    return AdminTeam(
      id: id,
      name: data['name'] ?? '',
      tag: data['tag'] ?? '',
      logoUrl: data['logoUrl'],
      captainUid: data['captainUid'] ?? '',
      memberUids: List<String>.from(data['memberUids'] ?? const []),
      maxMembers: data['maxMembers'] ?? 4,
      verified: data['verified'] ?? false,
      status: _statusFromString(data['status']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

/// One row of teams/{id}/members/{uid}.
class AdminTeamMember {
  final String uid;
  final String name;
  final String role;
  final bool isCaptain;
  final DateTime joinedAt;

  const AdminTeamMember({
    required this.uid,
    required this.name,
    required this.role,
    required this.isCaptain,
    required this.joinedAt,
  });

  factory AdminTeamMember.fromFirestore(String uid, Map<String, dynamic> data) {
    return AdminTeamMember(
      uid: uid,
      name: data['name'] ?? 'Unknown',
      role: data['role'] ?? 'Player',
      isCaptain: data['isCaptain'] ?? false,
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// A team awaiting admin approval.
class TeamApprovalRequest {
  final String id;
  final String name;
  final String tag;
  final String? logoUrl;

  const TeamApprovalRequest({
    required this.id,
    required this.name,
    required this.tag,
    this.logoUrl,
  });

  factory TeamApprovalRequest.fromFirestore(String id, Map<String, dynamic> data) {
    return TeamApprovalRequest(
      id: id,
      name: data['name'] ?? '',
      tag: data['tag'] ?? '',
      logoUrl: data['logoUrl'],
    );
  }
}