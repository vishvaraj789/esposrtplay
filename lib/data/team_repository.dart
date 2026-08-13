import '../models/team.dart';

class TeamRepository {
  TeamRepository._();

  static final List<Team> myTeams = [];

  /// Adds a team to the repository, or updates it in place if a team
  /// with the same name already exists.
  static void addOrUpdateTeam(Team team) {
    final index = myTeams.indexWhere((t) => t.teamName == team.teamName);
    if (index == -1) {
      myTeams.add(team);
    } else {
      myTeams[index] = team;
    }
  }
}