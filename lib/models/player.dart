class PlayerData {
  final String username;
  final String phone;
  final String playerUid;
  final String age;
  final String location;
  final String bio;
  final String role;
  final String gameMode;

  PlayerData({
    required this.username,
    required this.phone,
    required this.playerUid,
    required this.age,
    required this.location,
    required this.bio,
    required this.role,
    required this.gameMode,
  });
}

/// Full player profile with stats, used for the profile screen and
/// for identifying the current logged-in player (see data/player_data.dart).
class Player {
  final String name;
  final String email;
  final String uid;
  final String rank;
  final String team;
  final String country;
  final String bio;

  final int level;
  final int matches;
  final int wins;
  final int kills;
  final int headshots;

  final double kd;

  final int tournamentWins;
  final int mvp;
  final int totalDamage;

  final String favoriteWeapon;
  final String favoriteMap;
  final String favoriteMode;
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