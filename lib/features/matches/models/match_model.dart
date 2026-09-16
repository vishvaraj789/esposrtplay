import 'package:cloud_firestore/cloud_firestore.dart';

enum MatchStatus { upcoming, live, completed, cancelled }

MatchStatus matchStatusFromString(String s) =>
    MatchStatus.values.firstWhere((e) => e.name == s, orElse: () => MatchStatus.upcoming);

class MatchModel {
  final String id;
  final String tournamentId;
  final int round;
  final String teamAId;
  final String teamAName;
  final String teamBId;
  final String teamBName;
  final String? roomId;
  final String? roomPassword;
  final String map;
  final DateTime scheduledAt;
  final MatchStatus status;
  final String? winnerId;
  final String? winnerName;
  final DateTime createdAt;

  const MatchModel({
    required this.id,
    required this.tournamentId,
    required this.round,
    required this.teamAId,
    required this.teamAName,
    required this.teamBId,
    required this.teamBName,
    this.roomId,
    this.roomPassword,
    required this.map,
    required this.scheduledAt,
    this.status = MatchStatus.upcoming,
    this.winnerId,
    this.winnerName,
    required this.createdAt,
  });

  bool get isLive => status == MatchStatus.live;
  bool get isUpcoming => status == MatchStatus.upcoming;
  bool get isCompleted => status == MatchStatus.completed;
  bool get isCancelled => status == MatchStatus.cancelled;
  bool get hasWinner => winnerId != null;
  bool get hasRoomInfo => roomId != null && roomPassword != null;

  factory MatchModel.fromFirestore(String id, Map<String, dynamic> data) {
    return MatchModel(
      id: id,
      tournamentId: data['tournamentId'] ?? '',
      round: data['round'] ?? 1,
      teamAId: data['teamAId'] ?? '',
      teamAName: data['teamAName'] ?? 'TBD',
      teamBId: data['teamBId'] ?? '',
      teamBName: data['teamBName'] ?? 'TBD',
      roomId: data['roomId'],
      roomPassword: data['roomPassword'],
      map: data['map'] ?? '',
      scheduledAt: (data['scheduledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: matchStatusFromString(data['status'] ?? 'upcoming'),
      winnerId: data['winnerId'],
      winnerName: data['winnerName'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tournamentId': tournamentId,
      'round': round,
      'teamAId': teamAId,
      'teamAName': teamAName,
      'teamBId': teamBId,
      'teamBName': teamBName,
      'roomId': roomId,
      'roomPassword': roomPassword,
      'map': map,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'status': status.name,
      'winnerId': winnerId,
      'winnerName': winnerName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}