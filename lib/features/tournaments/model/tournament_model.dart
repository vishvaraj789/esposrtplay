import 'package:cloud_firestore/cloud_firestore.dart';

enum TournamentStatus { live, upcoming, completed, cancelled }
enum TournamentMode { solo, duo, squad, clashSquad }

TournamentStatus statusFromString(String s) =>
    TournamentStatus.values.firstWhere((e) => e.name == s, orElse: () => TournamentStatus.upcoming);

TournamentMode modeFromString(String s) =>
    TournamentMode.values.firstWhere((e) => e.name == s, orElse: () => TournamentMode.squad);

class Tournament {
  final String id;
  final String name;
  final TournamentStatus status;
  final TournamentMode mode;
  final String map;
  final DateTime startTime;
  final int maxParticipants; // max teams
  final int currentParticipants; // registered teams
  final double entryFee;
  final double prizePool;
  final Map<String, double> prizeBreakdown;
  final String createdBy;
  final DateTime createdAt;

  const Tournament({
    required this.id,
    required this.name,
    required this.status,
    required this.mode,
    required this.map,
    required this.startTime,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.entryFee,
    required this.prizePool,
    required this.prizeBreakdown,
    required this.createdBy,
    required this.createdAt,
  });

  bool get isFull => currentParticipants >= maxParticipants;

  factory Tournament.fromFirestore(String id, Map<String, dynamic> data) {
    return Tournament(
      id: id,
      name: data['name'] ?? '',
      status: statusFromString(data['status'] ?? 'upcoming'),
      mode: modeFromString(data['mode'] ?? 'squad'),
      map: data['map'] ?? '',
      startTime: (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      maxParticipants: data['maxParticipants'] ?? 0,
      currentParticipants: data['currentParticipants'] ?? 0,
      entryFee: (data['entryFee'] ?? 0).toDouble(),
      prizePool: (data['prizePool'] ?? 0).toDouble(),
      prizeBreakdown: Map<String, double>.from(
        (data['prizeBreakdown'] ?? {}).map((k, v) => MapEntry(k.toString(), (v as num).toDouble())),
      ),
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'status': status.name,
      'mode': mode.name,
      'map': map,
      'startTime': Timestamp.fromDate(startTime),
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'entryFee': entryFee,
      'prizePool': prizePool,
      'prizeBreakdown': prizeBreakdown,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

/// A team's registration for a specific tournament.
/// Lives at tournaments/{tournamentId}/registrations/{teamId}.
class TeamRegistration {
  final String teamId;
  final String teamName;
  final String? logoUrl;
  final bool checkedIn;
  final DateTime registeredAt;

  const TeamRegistration({
    required this.teamId,
    required this.teamName,
    this.logoUrl,
    this.checkedIn = false,
    required this.registeredAt,
  });

  factory TeamRegistration.fromFirestore(String teamId, Map<String, dynamic> data) {
    return TeamRegistration(
      teamId: teamId,
      teamName: data['teamName'] ?? 'Unknown Team',
      logoUrl: data['logoUrl'],
      checkedIn: data['checkedIn'] ?? false,
      registeredAt: (data['registeredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// Basic team info, read from the top-level teams/{teamId} collection.
class Team {
  final String id;
  final String name;
  final String? logoUrl;
  final List<String> memberUids;
  final String captainUid;

  const Team({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.memberUids,
    required this.captainUid,
  });

  factory Team.fromFirestore(String id, Map<String, dynamic> data) {
    return Team(
      id: id,
      name: data['name'] ?? '',
      logoUrl: data['logoUrl'],
      memberUids: List<String>.from(data['memberUids'] ?? []),
      captainUid: data['captainUid'] ?? '',
    );
  }
}

/// Top-level matches/{matchId} doc, linked via tournamentId + teamAId/teamBId.
class MatchModel {
  final String id;
  final String tournamentId;
  final int round;
  final int matchIndex;
  final String? teamAId;
  final String? teamBId;
  final String teamAName;
  final String teamBName;
  final int? scoreA;
  final int? scoreB;
  final String? winnerTeamId;
  final DateTime? scheduledTime;

  const MatchModel({
    required this.id,
    required this.tournamentId,
    required this.round,
    required this.matchIndex,
    this.teamAId,
    this.teamBId,
    this.teamAName = 'TBD',
    this.teamBName = 'TBD',
    this.scoreA,
    this.scoreB,
    this.winnerTeamId,
    this.scheduledTime,
  });

  bool get isComplete => winnerTeamId != null;

  factory MatchModel.fromFirestore(String id, Map<String, dynamic> data) {
    return MatchModel(
      id: id,
      tournamentId: data['tournamentId'] ?? '',
      round: data['round'] ?? 1,
      matchIndex: data['matchIndex'] ?? 0,
      teamAId: data['teamAId'],
      teamBId: data['teamBId'],
      teamAName: data['teamAName'] ?? 'TBD',
      teamBName: data['teamBName'] ?? 'TBD',
      scoreA: data['scoreA'],
      scoreB: data['scoreB'],
      winnerTeamId: data['winnerTeamId'],
      scheduledTime: (data['scheduledTime'] as Timestamp?)?.toDate(),
    );
  }
}

/// One row of leaderboard/{tournamentId}'s `entries` array field.
class LeaderboardEntry {
  final String teamId;
  final String teamName;
  final int rank;
  final int points;

  const LeaderboardEntry({
    required this.teamId,
    required this.teamName,
    required this.rank,
    required this.points,
  });

  factory LeaderboardEntry.fromMap(Map<String, dynamic> data) {
    return LeaderboardEntry(
      teamId: data['teamId'] ?? '',
      teamName: data['teamName'] ?? '',
      rank: data['rank'] ?? 0,
      points: data['points'] ?? 0,
    );
  }
}