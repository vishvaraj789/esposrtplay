import 'package:flutter/material.dart';
import '../../data/team_data.dart';
import '../../data/team_repository.dart';
import '../../models/team.dart';
import '../team/my_team_page.dart';

// Color Scheme (matches the rest of the app)
const bgColor = Color(0xFF0B0B10);
const surfaceColor = Color(0xFF17171F);
const accentColor = Color(0xFF8B5CF6);
const textColor = Colors.white;
const textSecondaryColor = Color(0xFF9797A8);

class TeamsScreen extends StatefulWidget {
  const TeamsScreen({super.key});

  @override
  State<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<TeamsScreen> {
  @override
  Widget build(BuildContext context) {
    final myTeam = TeamData.getTeam();
    final otherTeams = TeamRepository.myTeams
        .where((t) => myTeam == null || t.teamName != myTeam.teamName)
        .toList();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: const Text("Teams"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "My Team",
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          myTeam == null
              ? _EmptyMyTeamCard(
            onCreate: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyTeamPage()),
              );
            },
          )
              : _TeamCard(
            team: myTeam,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyTeamPage()),
              );
            },
          ),

          const SizedBox(height: 28),

          const Text(
            "All Teams",
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          if (otherTeams.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  "No teams to show yet.",
                  style: TextStyle(color: textSecondaryColor, fontSize: 14),
                ),
              ),
            )
          else
            ...otherTeams.map(
                  (team) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TeamCard(team: team, onTap: () {}),
              ),
            ),
        ],
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({required this.team, required this.onTap});

  final Team team;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: accentColor,
              child: Icon(Icons.shield_outlined, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team.teamName,
                    style: const TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${team.members.length} member${team.members.length == 1 ? '' : 's'}",
                    style: const TextStyle(
                      color: textSecondaryColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: textSecondaryColor),
          ],
        ),
      ),
    );
  }
}

class _EmptyMyTeamCard extends StatelessWidget {
  const _EmptyMyTeamCard({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "You don't have a team yet.",
            style: TextStyle(color: textColor, fontSize: 14),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Create Team",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: onCreate,
            ),
          ),
        ],
      ),
    );
  }
}