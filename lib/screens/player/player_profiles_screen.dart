import 'package:flutter/material.dart';

import '../../data/team_data.dart';
import '../../models/player.dart';

import '../../models/team_member.dart';
import 'player_list.dart';

class PlayerProfilesScreen extends StatefulWidget {
  final PlayerData? playerData;

  const PlayerProfilesScreen({
    super.key,
    this.playerData,
  });

  @override
  State<PlayerProfilesScreen> createState() => _PlayerProfilesScreenState();
}

class _PlayerProfilesScreenState extends State<PlayerProfilesScreen> {
  final Set<String> invitedPlayers = {};

  void _invitePlayer(Player player) {
    final team = TeamData.getTeam();

    if (team == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No team found. Please create a team first."),
        ),
      );
      return;
    }

    final alreadyExists =
    team.members.any((m) => m.playerUid == player.uid);

    if (alreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${player.name} is already in your team."),
        ),
      );
      return;
    }

    final members = List<TeamMember>.from(team.members);

    members.add(
      TeamMember(
        playerName: player.name,
        playerUid: player.uid,
        role: "Member",
        isCaptain: false,
      ),
    );

    TeamData.saveTeam(
      team.copyWith(members: members),
    );

    setState(() {
      invitedPlayers.add(player.uid);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${player.name} invited successfully."),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Players"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (widget.playerData != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Welcome ${widget.playerData!.username}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: allPlayers.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final player = allPlayers[index];
                final invited =
                invitedPlayers.contains(player.uid);

                return Card(
                  elevation: 3,
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        player.name[0].toUpperCase(),
                      ),
                    ),
                    title: Text(player.name),
                    subtitle: Text(
                      "UID: ${player.uid}\n"
                          "Rank: ${player.rank}\n"
                          "K/D: ${player.kd}",
                    ),
                    isThreeLine: true,
                    trailing: ElevatedButton(
                      onPressed: invited
                          ? null
                          : () => _invitePlayer(player),
                      child: Text(
                        invited ? "Invited" : "Invite",
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}