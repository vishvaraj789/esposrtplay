import '../models/team.dart';
import 'team_repository.dart';

class TeamData {
  static Team? _team;

  static void saveTeam(Team team) {
    _team = team;
    TeamRepository.addOrUpdateTeam(team);
  }

  static Team? getTeam() {
    return _team;
  }

  static void clearTeam() {
    _team = null;
  }
}