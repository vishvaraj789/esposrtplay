import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/player_admin_model.dart';

class PlayerAdminRepository {
  final FirebaseFirestore _firestore;

  PlayerAdminRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users => _firestore.collection('users');

  /// All players, newest first (sorted on the client so accounts without
  /// `createdAt` are still listed).
  Stream<List<AdminPlayer>> watchAllPlayers() {
    return _users.snapshots().map((snap) {
      final players = snap.docs.map((d) => AdminPlayer.fromFirestore(d.id, d.data())).toList();
      players.sort((a, b) => b.joinedAt.compareTo(a.joinedAt));
      return players;
    });
  }

  Stream<AdminPlayer?> watchPlayer(String uid) {
    return _users.doc(uid).snapshots().map(
          (doc) => doc.exists ? AdminPlayer.fromFirestore(doc.id, doc.data()!) : null,
    );
  }

  /// The player's team (first team whose memberUids contains them) and how
  /// many tournaments that team has registered for.
  Future<PlayerParticipation> fetchParticipation(String uid) async {
    final teamSnap = await _firestore
        .collection('teams')
        .where('memberUids', arrayContains: uid)
        .limit(1)
        .get();

    if (teamSnap.docs.isEmpty) return const PlayerParticipation();

    final teamDoc = teamSnap.docs.first;
    final count = await _firestore
        .collectionGroup('registrations')
        .where('teamId', isEqualTo: teamDoc.id)
        .count()
        .get();

    return PlayerParticipation(
      teamId: teamDoc.id,
      teamName: teamDoc.data()['name'] as String?,
      tournamentCount: count.count ?? 0,
    );
  }

  Future<void> setVerified(String uid, bool verified) {
    return _users.doc(uid).update({'verified': verified});
  }

  Future<void> setStatus(String uid, PlayerStatus status) {
    return _users.doc(uid).update({'status': status.name});
  }
}