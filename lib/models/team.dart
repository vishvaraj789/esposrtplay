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

  Team copyWith({
    String? teamName,
    String? teamLogo,
    List<TeamMember>? members,
  }) {
    return Team(
      teamName: teamName ?? this.teamName,
      teamLogo: teamLogo ?? this.teamLogo,
      members: members ?? this.members,
    );
  }
}