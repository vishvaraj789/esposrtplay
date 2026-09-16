class AdminStats {
  final int totalTournaments;
  final int totalTeams;
  final int matchesToday;
  final double totalPrizePool;

  const AdminStats({
    required this.totalTournaments,
    required this.totalTeams,
    required this.matchesToday,
    required this.totalPrizePool,
  });

  factory AdminStats.empty() => const AdminStats(
    totalTournaments: 0,
    totalTeams: 0,
    matchesToday: 0,
    totalPrizePool: 0,
  );
}