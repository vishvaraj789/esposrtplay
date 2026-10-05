import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/team_admin_model.dart';

class TeamAdminRepository {
  final FirebaseFirestore _firestore;

  TeamAdminRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _teams => _firestore.collection('teams');

  /// All teams, newest first. Sorted on the client so teams that predate the
  /// `createdAt` field are still listed (a Firestore orderBy would drop them).
  Stream<List<AdminTeam>> watchAllTeams() {
    return _teams.snapshots().map((snap) {
      final teams = snap.docs.map((d) => AdminTeam.fromFirestore(d.id, d.data())).toList();
      teams.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return teams;
    });
  }

  Stream<AdminTeam?> watchTeam(String teamId) {
    return _teams.doc(teamId).snapshots().map(
          (doc) => doc.exists ? AdminTeam.fromFirestore(doc.id, doc.data()!) : null,
    );
  }

  Stream<List<AdminTeamMember>> watchMembers(String teamId) {
    return _teams.doc(teamId).collection('members').orderBy('joinedAt').snapshots().map(
          (snap) => snap.docs.map((d) => AdminTeamMember.fromFirestore(d.id, d.data())).toList(),
    );
  }

  /// How many tournaments this team has registered for.
  Future<int> fetchTournamentCount(String teamId) async {
    final result = await _firestore
        .collectionGroup('registrations')
        .where('teamId', isEqualTo: teamId)
        .count()
        .get();
    return result.count ?? 0;
  }

  Future<void> setVerified(String teamId, bool verified) {
    return _teams.doc(teamId).update({'verified': verified});
  }

  Future<void> setStatus(String teamId, TeamStatus status) {
    return _teams.doc(teamId).update({'status': status.name});
  }

  /// Removes a non-captain member from the team (both the memberUids array
  /// and their member document, in one atomic batch).
  Future<void> removeMember({required String teamId, required String uid}) async {
    final teamRef = _teams.doc(teamId);
    final snap = await teamRef.get();
    if (snap.data()?['captainUid'] == uid) {
      throw Exception('The captain cannot be removed. Suspend the team instead.');
    }

    final batch = _firestore.batch();
    batch.update(teamRef, {'memberUids': FieldValue.arrayRemove([uid])});
    batch.delete(teamRef.collection('members').doc(uid));
    await batch.commit();
  }
}