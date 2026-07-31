import 'package:flutter/material.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/info_card.dart';
import 'join_tournament_screen.dart';
class TournamentDetailsScreen extends StatelessWidget {
  final String title;
  final String mode;
  final String prize;
  final String status;
  final String tournamentId;
  final String map;
  final String matchType;
  final String maxPlayers;
  final String registeredPlayers;

  const TournamentDetailsScreen({
    super.key,
    required this.title,
    required this.mode,
    required this.prize,
    required this.status,
    required this.tournamentId,
    required this.map,
    required this.matchType,
    required this.maxPlayers,
    required this.registeredPlayers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tournament Details"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 45,
              child: Icon(
                Icons.emoji_events,
                size: 45,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: const SizedBox(),
            ),

            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    InfoCard(
                      icon: Icons.tag,
                      title: "Tournament ID",
                      value: tournamentId,
                    ),

                    InfoCard(
                      icon: Icons.sports_esports,
                      title: "Mode",
                      value: mode,
                    ),

                    InfoCard(
                      icon: Icons.map,
                      title: "Map",
                      value: map,
                    ),

                    InfoCard(
                      icon: Icons.gamepad,
                      title: "Match Type",
                      value: matchType,
                    ),

                    InfoCard(
                      icon: Icons.groups,
                      title: "Players",
                      value: "$registeredPlayers / $maxPlayers",
                    ),

                    InfoCard(
                      icon: Icons.currency_rupee,
                      title: "Prize",
                      value: prize,
                    ),

                    const InfoCard(
                      icon: Icons.calendar_month,
                      title: "Date",
                      value: "25 July 2026",
                    ),

                    const InfoCard(
                      icon: Icons.access_time,
                      title: "Time",
                      value: "8:00 PM",
                    ),

                    InfoCard(
                      icon: Icons.flag,
                      title: "Status",
                      value: status,
                      valueStyle: TextStyle(
                        color: status == "Open"
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const InfoCard(
                      icon: Icons.payments,
                      title: "Entry Fee",
                      value: "₹50",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            PrimaryButton(
              text: "Join Tournament",
              icon: Icons.emoji_events,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JoinTournamentScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}