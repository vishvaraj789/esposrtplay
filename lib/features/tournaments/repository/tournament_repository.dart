import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/tournament_model.dart';

class TournamentRepository {
  final FirebaseFirestore _firestore;

  TournamentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _tournaments => _firestore.collection('tournaments');
  CollectionReference<Map<String, dynamic>> get _matches => _firestore.collection('matches');
  CollectionReference<Map<String, dynamic>> get _teams => _firestore.collection('teams');
  CollectionReference<Map<String, dynamic>> get _leaderboard => _firestore.collection('leaderboard');

  // --- Tournaments ---

  Stream<List<Tournament>> watchTournaments({TournamentStatus? status}) {
    Query<Map<String, dynamic>> query = _tournaments.orderBy('startTime');
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }
    return query.snapshots().map(
          (snap) => snap.docs.map((d) => Tournament.fromFirestore(d.id, d.data())).toList(),
    );
  }

  Stream<Tournament?> watchTournament(String id) {
    return _tournaments.doc(id).snapshots().map(
          (doc) => doc.exists ? Tournament.fromFirestore(doc.id, doc.data()!) : null,
    );
  }

  Future<String> createTournament(Tournament tournament) async {
    final ref = await _tournaments.add(tournament.toFirestore());
    return ref.id;
  }

  // --- Team registrations (subcollection under a tournament) ---

  Stream<List<TeamRegistration>> watchRegistrations(String tournamentId) {
    return _tournaments
        .doc(tournamentId)
        .collection('registrations')
        .snapshots()
        .map((snap) => snap.docs.map((d) => TeamRegistration.fromFirestore(d.id, d.data())).toList());
  }

  Future<void> registerTeam({
    required String tournamentId,
    required String teamId,
    required String teamName,
    String? logoUrl,
  }) async {
    final tournamentRef = _tournaments.doc(tournamentId);

    await _firestore.runTransaction((txn) async {
      final snap = await txn.get(tournamentRef);
      final data = snap.data();
      if (data == null) throw Exception('Tournament not found');

      final current = data['currentParticipants'] ?? 0;
      final max = data['maxParticipants'] ?? 0;
      if (current >= max) throw Exception('Tournament is full');

      final regRef = tournamentRef.collection('registrations').doc(teamId);
      final existing = await txn.get(regRef);
      if (existing.exists) throw Exception('Team already registered');

      txn.set(regRef, {
        'teamName': teamName,
        'logoUrl': logoUrl,
        'checkedIn': false,
        'registeredAt': FieldValue.serverTimestamp(),
      });
      txn.update(tournamentRef, {'currentParticipants': current + 1});
    });
  }

  // --- Teams ---

  Stream<List<Team>> watchTeamsForUser(String uid) {
    return _teams
        .where('memberUids', arrayContains: uid)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Team.fromFirestore(d.id, d.data())).toList());
  }

  // --- Matches (top-level, filtered by tournamentId) ---

  Stream<List<MatchModel>> watchMatches(String tournamentId) {
    return _matches
        .where('tournamentId', isEqualTo: tournamentId)
        .orderBy('round')
        .snapshots()
        .map((snap) => snap.docs.map((d) => MatchModel.fromFirestore(d.id, d.data())).toList());
  }

  Future<void> submitMatchResult({
    required String matchId,
    required int scoreA,
    required int scoreB,
    required String winnerTeamId,
  }) {
    return _matches.doc(matchId).update({
      'scoreA': scoreA,
      'scoreB': scoreB,
      'winnerTeamId': winnerTeamId,
    });
  }

  // --- Leaderboard (single doc per tournament) ---

  Stream<List<LeaderboardEntry>> watchLeaderboard(String tournamentId) {
    return _leaderboard.doc(tournamentId).snapshots().map((doc) {
      final data = doc.data();
      if (data == null || data['entries'] == null) return <LeaderboardEntry>[];
      final entries = (data['entries'] as List)
          .map((e) => LeaderboardEntry.fromMap(Map<String, dynamic>.from(e)))
          .toList();
      entries.sort((a, b) => a.rank.compareTo(b.rank));
      return entries;
    });
  }
}