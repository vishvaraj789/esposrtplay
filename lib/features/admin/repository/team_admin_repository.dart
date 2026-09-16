import 'package:cloud_firestore/cloud_firestore.dart';

enum TeamApprovalStatus { pending, approved, rejected }

TeamApprovalStatus _approvalFromString(String s) =>
    TeamApprovalStatus.values.firstWhere((e) => e.name == s, orElse: () => TeamApprovalStatus.pending);

class TeamApprovalRequest {
  final String teamId;
  final String name;
  final String tag;
  final String? logoUrl;
  final String captainUid;
  final TeamApprovalStatus status;
  final DateTime createdAt;

  const TeamApprovalRequest({
    required this.teamId,
    required this.name,
    required this.tag,
    this.logoUrl,
    required this.captainUid,
    required this.status,
    required this.createdAt,
  });

  factory TeamApprovalRequest.fromFirestore(String id, Map<String, dynamic> data) {
    return TeamApprovalRequest(
      teamId: id,
      name: data['name'] ?? '',
      tag: data['tag'] ?? '',
      logoUrl: data['logoUrl'],
      captainUid: data['captainUid'] ?? '',
      status: _approvalFromString(data['approvalStatus'] ?? 'pending'),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class TeamAdminRepository {
  final FirebaseFirestore _firestore;

  TeamAdminRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _teams => _firestore.collection('teams');

  Stream<List<TeamApprovalRequest>> watchPendingTeams() {
    return _teams
        .where('approvalStatus', isEqualTo: TeamApprovalStatus.pending.name)
        .snapshots()
        .map((snap) => snap.docs.map((d) => TeamApprovalRequest.fromFirestore(d.id, d.data())).toList());
  }

  Stream<List<TeamApprovalRequest>> watchAllTeams() {
    return _teams
        .snapshots()
        .map((snap) => snap.docs.map((d) => TeamApprovalRequest.fromFirestore(d.id, d.data())).toList());
  }

  Future<void> approveTeam(String teamId) {
    return _teams.doc(teamId).update({'approvalStatus': TeamApprovalStatus.approved.name});
  }

  Future<void> rejectTeam(String teamId) {
    return _teams.doc(teamId).update({'approvalStatus': TeamApprovalStatus.rejected.name});
  }
}