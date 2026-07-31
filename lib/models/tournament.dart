class Tournament {
  final String title;
  final String mode;
  final String prize;
  final String status;
  final String tournamentId;
  final String map;
  final String matchType;
  final String maxPlayers;
  final String registeredPlayers;

  bool isFavorite;

  Tournament({
    required this.title,
    required this.mode,
    required this.prize,
    required this.status,
    required this.tournamentId,
    required this.map,
    required this.matchType,
    required this.maxPlayers,
    required this.registeredPlayers,
    this.isFavorite = false,
  });
}