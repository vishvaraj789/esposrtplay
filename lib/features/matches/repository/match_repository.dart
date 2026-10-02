import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/match_model.dart';

class MatchRepository {
  final FirebaseFirestore _firestore;

  MatchRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _matches => _firestore.collection('matches');

  Future<String> createMatch({
    required String tournamentId,
    required int round,
    int matchIndex = 0,
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
      'matchIndex': matchIndex,
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

  /// Matches for a tournament, ordered for correct bracket display:
  /// by round first, then by matchIndex within that round. Firestore
  /// can't orderBy two fields without a composite index unless we sort
  /// the second field client-side, which is cheap for match-list sizes.
  Stream<List<MatchModel>> watchMatchesForTournament(String tournamentId) {
    return _matches
        .where('tournamentId', isEqualTo: tournamentId)
        .orderBy('round')
        .snapshots()
        .map((snap) {
      final matches = snap.docs.map((d) => MatchModel.fromFirestore(d.id, d.data())).toList();
      matches.sort((a, b) {
        final roundCompare = a.round.compareTo(b.round);
        if (roundCompare != 0) return roundCompare;
        return a.matchIndex.compareTo(b.matchIndex);
      });
      return matches;
    });
  }

  Stream<MatchModel?> watchMatch(String matchId) {
    return _matches.doc(matchId).snapshots().map(
          (doc) => doc.exists ? MatchModel.fromFirestore(doc.id, doc.data()!) : null,
    );
  }

  Future<void> startMatch({required String matchId, required String roomId, required String roomPassword}) {
    return _matches.doc(matchId).update({
      'roomId': roomId,
      'roomPassword': roomPassword,
      'status': MatchStatus.live.name,
    });
  }

  Future<void> endMatch(String matchId) {
    return _matches.doc(matchId).update({'status': MatchStatus.completed.name});
  }

  Future<void> declareWinner({required String matchId, required String winnerId, required String winnerName}) {
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