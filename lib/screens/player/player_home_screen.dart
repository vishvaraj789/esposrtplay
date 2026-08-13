import 'package:flutter/material.dart';
import '../../models/player.dart';
import 'player_profiles_screen.dart';
import '../tournament/tournament_screen.dart';
import 'teams_screen.dart';

// Color Scheme (matches the rest of the app)
const bgColor = Color(0xFF0B0B10);
const surfaceColor = Color(0xFF17171F);
const accentColor = Color(0xFF8B5CF6);
const textColor = Colors.white;
const textSecondaryColor = Color(0xFF9797A8);

class PlayerHomeScreen extends StatefulWidget {
  const PlayerHomeScreen({super.key, required this.playerData});

  final PlayerData playerData;

  @override
  State<PlayerHomeScreen> createState() => _PlayerHomeScreenState();
}

class _PlayerHomeScreenState extends State<PlayerHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeTab(playerData: widget.playerData),
      const _PlaceholderTab(
        icon: Icons.emoji_events_outlined,
        label: "Tournament",
      ),
      const _PlaceholderTab(
        icon: Icons.groups_outlined,
        label: "Teams",
      ),
      const _PlaceholderTab(
        icon: Icons.settings_outlined,
        label: "Settings",
      ),
    ];

    final titles = ["Home", "Tournament", "Teams", "Settings"];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(titles[_selectedIndex]),
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TournamentScreen()),
            );
            return;
          }
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TeamsScreen()),
            );
            return;
          }
          setState(() => _selectedIndex = index);
        },
        backgroundColor: surfaceColor,
        selectedItemColor: accentColor,
        unselectedItemColor: textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            activeIcon: Icon(Icons.emoji_events),
            label: "Tournament",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.groups),
            label: "Teams",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.playerData});

  final PlayerData playerData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome header
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: accentColor,
                child: Icon(Icons.person, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome back,",
                      style: TextStyle(color: textSecondaryColor, fontSize: 14),
                    ),
                    Text(
                      playerData.username,
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Quick info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _InfoTile(label: "Role", value: playerData.role),
                ),
                Expanded(
                  child: _InfoTile(label: "Game Mode", value: playerData.gameMode),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // View profile action
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.badge_outlined, color: Colors.white),
              label: const Text(
                "View My Profile",
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlayerProfilesScreen(playerData: playerData),
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

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: textSecondaryColor),
          const SizedBox(height: 12),
          Text(
            "$label coming soon",
            style: const TextStyle(color: textSecondaryColor, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: textSecondaryColor, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? "-" : value,
          style: const TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}