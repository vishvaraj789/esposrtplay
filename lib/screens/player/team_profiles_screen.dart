import 'package:flutter/material.dart';
import '../../models/player.dart';

class TeamProfilesScreen extends StatefulWidget {
  final PlayerData playerData;

  const TeamProfilesScreen({super.key, required this.playerData});

  @override
  State<TeamProfilesScreen> createState() => _TeamProfilesScreenState();
}

class _TeamProfilesScreenState extends State<TeamProfilesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("team_profiles"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          "Welcome, ${widget.playerData.username}!\n"
              "Role: ${widget.playerData.role}\n"
              "Game Mode: ${widget.playerData.gameMode}",
        ),
      ),
    );
  }
}