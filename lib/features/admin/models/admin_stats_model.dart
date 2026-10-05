class AdminStats {
  final int totalPlayers;
  final int totalTeams;
  final int totalTournaments;
  final int liveTournaments;
  final int upcomingTournaments;
  final int completedTournaments;

  const AdminStats({
    required this.totalPlayers,
    required this.totalTeams,
    required this.totalTournaments,
    required this.liveTournaments,
    required this.upcomingTournaments,
    required this.completedTournaments,
  });

  factory AdminStats.empty() => const AdminStats(
    totalPlayers: 0,
    totalTeams: 0,
    totalTournaments: 0,
    liveTournaments: 0,
    upcomingTournaments: 0,
    completedTournaments: 0,
  );
}

enum AdminActivityType { player, team, tournament }

/// One row in the dashboard's "Recent Activity" list.
class AdminActivity {
  final AdminActivityType type;
  final String title;
  final String subtitle;
  final DateTime time;

  const AdminActivity({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}