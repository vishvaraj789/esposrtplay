class Player {
  String name;
  String email;
  final String uid;
  final String rank;

  String team;
  String country;
  String bio;

  final int level;
  final int matches;
  final int wins;
  final int kills;
  final int headshots;
  final int tournamentWins;
  final int mvp;
  final int totalDamage;

  final double kd;

  String favoriteWeapon;
  String favoriteMap;
  String favoriteMode;

  final String guild;

  final List<String> achievements;

  final String profileImage;

  Player({
    required this.name,
    required this.email,
    required this.uid,
    required this.rank,
    required this.team,
    required this.country,
    required this.bio,
    required this.level,
    required this.matches,
    required this.wins,
    required this.kills,
    required this.headshots,
    required this.kd,
    required this.tournamentWins,
    required this.mvp,
    required this.totalDamage,
    required this.favoriteWeapon,
    required this.favoriteMap,
    required this.favoriteMode,
    required this.guild,
    required this.achievements,
    required this.profileImage,
  });
}