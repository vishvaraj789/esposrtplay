import 'package:eposrtplay/screens/team/home_page.dart';
import 'package:eposrtplay/screens/team/my_team_page.dart';
import 'package:eposrtplay/screens/team/settings_page.dart';
import '../tournament/tournament_screen.dart';
import 'package:flutter/material.dart';

// Color Scheme
const bgColor = Color(0xFF0B0B10);
const surfaceColor = Color(0xFF17171F);
const accentColor = Color(0xFF8B5CF6);
const textColor = Colors.white;
const textSecondaryColor = Color(0xFF9797A8);

class TeamHomeScreen extends StatefulWidget {
  const TeamHomeScreen({super.key});

  @override
  State<TeamHomeScreen> createState() => _TeamHomeScreenState();
}

class _TeamHomeScreenState extends State<TeamHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const TournamentScreen(),
    const MyTeamPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: surfaceColor,
        elevation: 20,
        enableFeedback: true,
        selectedItemColor: accentColor,
        unselectedItemColor: textSecondaryColor,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            activeIcon: Icon(Icons.home_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_rounded),
            activeIcon: Icon(Icons.emoji_events_rounded),
            label: "Tournament",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_rounded),
            activeIcon: Icon(Icons.groups_rounded),
            label: "My Team",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            activeIcon: Icon(Icons.settings_rounded),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}