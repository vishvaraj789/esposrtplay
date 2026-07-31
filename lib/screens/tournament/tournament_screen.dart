import 'package:flutter/material.dart';
import '../../data/dummy_data.dart';
import '../../models/tournament.dart';
import 'tournament_details_screen.dart';

class TournamentScreen extends StatefulWidget {
  const TournamentScreen({super.key});

  @override
  State<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> {
  final TextEditingController searchController = TextEditingController();

  late List<Tournament> filteredTournaments;

  @override
  void initState() {
    super.initState();
    filteredTournaments = List.from(tournaments);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void searchTournament(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        filteredTournaments = List.from(tournaments);
      } else {
        filteredTournaments = tournaments.where((tournament) {
          return tournament.title
              .toLowerCase()
              .contains(query.toLowerCase()) ||
              tournament.mode
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              tournament.map
                  .toLowerCase()
                  .contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Free Fire Tournaments"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: searchTournament,
              decoration: InputDecoration(
                hintText: "Search Tournament...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: filteredTournaments.isEmpty
                  ? const Center(
                child: Text(
                  "No tournaments found",
                  style: TextStyle(fontSize: 18),
                ),
              )
                  : ListView.builder(
                itemCount: filteredTournaments.length,
                itemBuilder: (context, index) {
                  final tournament = filteredTournaments[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.emoji_events),
                      ),
                      title: Text(
                        tournament.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Mode: ${tournament.mode}"),
                          Text("Map: ${tournament.map}"),
                          Text("Prize: ${tournament.prize}"),
                          Text("Status: ${tournament.status}"),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TournamentDetailsScreen(
                                title: tournament.title,
                                mode: tournament.mode,
                                prize: tournament.prize,
                                status: tournament.status,
                                tournamentId: tournament.tournamentId,
                                map: tournament.map,
                                matchType: tournament.matchType,
                                maxPlayers: tournament.maxPlayers,
                                registeredPlayers: tournament.registeredPlayers,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}