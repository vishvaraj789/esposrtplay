import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/match_model.dart';

class MatchRepository {
  final FirebaseFirestore _firestore;

  MatchRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _matches => _firestore.collection('matches');

  // --- Create (admin) ---

  Future<String> createMatch({
    required String tournamentId,
    required int round,
    required String teamAId,
    required String teamAName,
    required String teamBId,
    required String teamBName,
    required String map,
    required DateTime scheduledAt,
  }) async {
    final ref = await _matches.add({
      'tournamentId': tournamentId,
      'round': round,
      'teamAId': teamAId,
      'teamAName': teamAName,
      'teamBId': teamBId,
      'teamBName': teamBName,
      'roomId': null,
      'roomPassword': null,
      'map': map,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'status': MatchStatus.upcoming.name,
      'winnerId': null,
      'winnerName': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  // --- Reads ---

  Stream<List<MatchModel>> watchUpcomingMatches() {
    return _matches
        .where('status', isEqualTo: MatchStatus.upcoming.name)
        .orderBy('scheduledAt')
        .snapshots()
        .map((snap) => snap.docs.map((d) => MatchModel.fromFirestore(d.id, d.data())).toList());
  }

  Stream<List<MatchModel>> watchLiveMatches() {
    return _matches
        .where('status', isEqualTo: MatchStatus.live.name)
        .snapshots()
        .map((snap) => snap.docs.map((d) => MatchModel.fromFirestore(d.id, d.data())).toList());
  }

  Stream<List<MatchModel>> watchMatchesForTournament(String tournamentId) {
    return _matches
        .where('tournamentId', isEqualTo: tournamentId)
        .orderBy('round')
        .snapshots()
        .map((snap) => snap.docs.map((d) => MatchModel.fromFirestore(d.id, d.data())).toList());
  }

  Stream<MatchModel?> watchMatch(String matchId) {
    return _matches.doc(matchId).snapshots().map(
          (doc) => doc.exists ? MatchModel.fromFirestore(doc.id, doc.data()!) : null,
    );
  }

  // --- Admin actions ---

  /// Starts the match: reveals room credentials and flips status to live.
  Future<void> startMatch({
    required String matchId,
    required String roomId,
    required String roomPassword,
  }) {
    return _matches.doc(matchId).update({
      'roomId': roomId,
      'roomPassword': roomPassword,
      'status': MatchStatus.live.name,
    });
  }

  /// Ends the match session without necessarily declaring a winner yet
  /// (e.g. admin closes the room after the match wraps up in-game).
  Future<void> endMatch(String matchId) {
    return _matches.doc(matchId).update({'status': MatchStatus.completed.name});
  }

  /// Declares a winner. Also ensures status is completed, in case this is
  /// called directly from a live match without a separate "end" step.
  Future<void> declareWinner({
    required String matchId,
    required String winnerId,
    required String winnerName,
  }) {
    return _matches.doc(matchId).update({
      'winnerId': winnerId,
      'winnerName': winnerName,
      'status': MatchStatus.completed.name,
    });
  }

  Future<void> cancelMatch(String matchId) {
    return _matches.doc(matchId).update({'status': MatchStatus.cancelled.name});
  }
}