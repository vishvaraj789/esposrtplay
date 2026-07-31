import 'team_member.dart';

class Team {
  final String teamName;
  final String teamLogo;
  final List<TeamMember> members;

  Team({
    required this.teamName,
    required this.teamLogo,
    required this.members,
  });
}