import 'package:flutter/material.dart';
import '../../models/player.dart';
import 'player_home_screen.dart';
class PlayerProfilesScreen extends StatefulWidget{
  const PlayerProfilesScreen({super.key,
    this.playerData});

  final PlayerData? playerData;

  @override
  State<PlayerProfilesScreen> createState() => _PlayerProfilesScreenState();
}

class _PlayerProfilesScreenState extends State<PlayerProfilesScreen>{

  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(
          title: const Text("Player Profiles"),
          centerTitle: true,
        ),

        body: widget.playerData == null
            ? const Center(
          child: Text(
            "No player data available.",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        )
            : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Colors.white10,
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.deepPurpleAccent,
                            child: Icon(Icons.person, color: Colors.white, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.playerData!.username,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "UID: ${widget.playerData!.playerUid}",
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 32, color: Colors.white24),
                      _ProfileRow(label: "Role", value: widget.playerData!.role),
                      _ProfileRow(label: "Game Mode", value: widget.playerData!.gameMode),
                      _ProfileRow(label: "Age", value: widget.playerData!.age),
                      _ProfileRow(label: "Location", value: widget.playerData!.location),
                      _ProfileRow(label: "Phone", value: widget.playerData!.phone),
                      if (widget.playerData!.bio.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Text(
                          "Bio",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.playerData!.bio,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                      const SizedBox(height: 16),

                      ElevatedButton.icon(
                        icon: const Icon(Icons.home_outlined, color: Colors.white),
                        onPressed: (){
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PlayerHomeScreen(playerData: widget.playerData!),
                            ),
                          );
                        },
                        label: const Text("home"),
                      ),
                    ],
                  ),
                ),
              ),

            ]
        )
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}