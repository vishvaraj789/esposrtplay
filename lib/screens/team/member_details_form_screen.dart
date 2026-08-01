import 'package:flutter/material.dart';

import '../../models/team.dart';
import '../../models/team_member.dart';
import 'team_detail_screen.dart';
import '../../data/team_data.dart';

class MemberDetailsFormScreen extends StatefulWidget {
  final int playerCount;
  final String teamName;
  final String? teamLogoPath;

  const MemberDetailsFormScreen({
    super.key,
    required this.playerCount,
    required this.teamName,
    this.teamLogoPath,
  });
  @override
  State<MemberDetailsFormScreen> createState() => _MemberDetailsScreenState();
}

class _MemberDetailsScreenState extends State<MemberDetailsFormScreen> {
  late List<TextEditingController> playerNameControllers;
  late List<TextEditingController> playerUidControllers;
  late List<String> selectedRoles;

  final List<String> roles = [
    "Rusher",
    "Secondary Rusher",
    "Sniper",
    "Support",
    "Grenadier/IGL"
  ];

  @override
  void initState() {
    super.initState();

    playerNameControllers = List.generate(
      widget.playerCount,
          (_) => TextEditingController(),
    );

    playerUidControllers = List.generate(
      widget.playerCount,
          (_) => TextEditingController(),
    );

    selectedRoles = List.generate(
      widget.playerCount,
          (_) => roles.first,
    );
  }

  @override
  void dispose() {
    for (var controller in playerNameControllers) {
      controller.dispose();
    }

    for (var controller in playerUidControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  /// Builds a Team object from whatever the user typed into the form.
  /// Player 1 is treated as the captain/IGL of the roster.
  Team _buildTeamFromForm() {
    final members = List.generate(widget.playerCount, (i) {
      final name = playerNameControllers[i].text.trim();
      final uid = playerUidControllers[i].text.trim();
      return TeamMember(
        playerName: name.isEmpty ? 'Player ${i + 1}' : name,
        playerUid: uid.isEmpty ? '-' : uid,
        role: selectedRoles[i],
        isCaptain: i == 0,
      );
    });

    return Team(
      teamName: widget.teamName,
      teamLogo: widget.teamLogoPath ?? "",
      members: members,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Member Details"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...List.generate(widget.playerCount, (index) {
            return Card(
              color: Colors.white10,
              margin: const EdgeInsets.only(bottom: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      "Player ${index + 1}",
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.orange,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: playerNameControllers[index],
                      decoration: const InputDecoration(
                        labelText: "Player Name",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller: playerUidControllers[index],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Player UID",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge),
                      ),
                    ),

                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      value: selectedRoles[index],
                      decoration: const InputDecoration(
                        labelText: "Game Role",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.sports_esports),
                      ),
                      items: roles.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRoles[index] = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          }),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                final team = _buildTeamFromForm();

                // Save team in team_data.dart
                TeamData.saveTeam(team);

                for (final member in team.members) {
                  debugPrint(
                    "${member.playerName}, ${member.playerUid}, ${member.role}",
                  );
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Members Saved Successfully"),
                  ),
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TeamDetailScreen(),
                  ),
                );
              },
              child: const Text(
                "Submit",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}