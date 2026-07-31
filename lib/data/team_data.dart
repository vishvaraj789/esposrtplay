import '../models/team.dart';

class TeamData {
  static Team? _team;

  static void saveTeam(Team team) {
    _team = team;
  }

  static Team? getTeam() {
    return _team;
  }

  static void clearTeam() {
    _team = null;
  }
}