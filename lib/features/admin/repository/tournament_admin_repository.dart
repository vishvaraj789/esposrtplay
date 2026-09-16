import 'package:cloud_firestore/cloud_firestore.dart';

import '../../tournaments/model/tournament_model.dart';

/// Admin-side tournament operations. Unlike the player-facing
/// TournamentRepository, this can see and edit tournaments regardless of
/// status, and can delete them outright.
class TournamentAdminRepository {
  final FirebaseFirestore _firestore;

  TournamentAdminRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _tournaments => _firestore.collection('tournaments');

  Stream<List<Tournament>> watchAllTournaments() {
    return _tournaments
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Tournament.fromFirestore(d.id, d.data())).toList());
  }

  Future<void> updateTournament(String id, Map<String, dynamic> updates) {
    return _tournaments.doc(id).update(updates);
  }

  Future<void> deleteTournament(String id) {
    return _tournaments.doc(id).delete();
  }

  Future<void> setStatus(String id, TournamentStatus status) {
    return _tournaments.doc(id).update({'status': status.name});
  }
}