import 'dart:io';
import 'package:flutter/material.dart';

import '../../data/team_data.dart';
import '../player/player_profiles_screen.dart';
import 'team_home_screen.dart';

class TeamDetailScreen extends StatelessWidget {
  const TeamDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final team = TeamData.getTeam();

    if (team == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Team Details"),
        ),
        body: const Center(
          child: Text("No Team Data Found"),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(team.teamName),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            CircleAvatar(
              radius: 60,
              backgroundImage: team.teamLogo.isNotEmpty
                  ? FileImage(File(team.teamLogo))
                  : null,
              child: team.teamLogo.isEmpty
                  ? const Icon(Icons.groups)
                  : null,
            ),

            const SizedBox(height: 20),

            Text(
              team.teamName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: team.members.length,
                itemBuilder: (context, index) {
                  final member = team.members[index];

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text("${index + 1}"),
                      ),
                      title: Text(member.playerName),
                      subtitle: Text(
                        "UID: ${member.playerUid}\nRole: ${member.role}",
                      ),
                      trailing: member.isCaptain
                          ? const Icon(
                        Icons.star,
                        color: Colors.orange,
                      )
                          : null,
                    ),
                  );
                },
              ),
            ),
            ElevatedButton.icon(
                onPressed: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PlayerProfilesScreen()
                      ),
                  );
                },
                label: const Text("Your need Player"),
                icon: const Icon(Icons.person),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
                onPressed: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const TeamHomeScreen()
                      ));
                },
                icon: const Icon(Icons.check),
                label: const Text("Completed"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}