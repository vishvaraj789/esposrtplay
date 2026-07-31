
import 'package:flutter/material.dart';

class JoinTournamentScreen extends StatefulWidget {
  const JoinTournamentScreen({super.key});

  @override
  State<JoinTournamentScreen> createState() =>
      _JoinTournamentScreenState();
}

class _JoinTournamentScreenState
    extends State<JoinTournamentScreen> {

  bool isJoined = false;
  bool isFavorite = false;

  int joinedPlayers = 32;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Join Tournament"),
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Icon(
                  Icons.emoji_events,
                  size: 60,
                ),

                const SizedBox(height: 20),

                const Text(
                  "Weekly Clash",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  isJoined
                      ? "Status: Joined ✅"
                      : "Status: Not Joined",
                  style: TextStyle(
                    fontSize: 18,
                    color: isJoined
                        ? Colors.green
                        : Colors.red,
                  ),
                ),

                const SizedBox(height: 25),

                ElevatedButton(
                  onPressed: isJoined
                      ? null
                      : () {
                    setState(() {
                      isJoined = true;
                      joinedPlayers++;
                    });
                  },
                  child: Text(
                    isJoined ? "Joined" : "Join Tournament",
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFavorite ? Colors.red : null,
                  ),
                  onPressed: () {
                    setState(() {
                      isFavorite = !isFavorite;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isFavorite
                              ? "Added to Favorites ❤️"
                              : "Removed from Favorites",
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                  ),
                  label: Text(
                    isFavorite
                        ? "Favorited"
                        : "Favorite",
                  ),
                ),
                 const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (!isJoined) {
                        isJoined = true;
                        joinedPlayers++;
                      } else {
                        isJoined = false;
                        joinedPlayers--;
                      }
                    });
                  },
                  child: Text(
                    "Players Joined: $joinedPlayers",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}