import 'package:flutter/material.dart';

import '../team/home_page.dart';
import '../tournament/tournament_screen.dart';
import '../player/join_as_player.dart';
import '../team/join_as_team.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabController;

  static const List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.home,
      label: "Home",
      page: HomePage(),
      notificationCount: 0,
    ),
    _NavItem(
      icon: Icons.emoji_events,
      label: "Tournament",
      page: TournamentScreen(),
      notificationCount: 2,
    ),
    _NavItem(
      icon: Icons.person,
      label: "Profile",
      page: JoinAsPlayerForm(),
      notificationCount: 0,
    ),
    _NavItem(
      icon: Icons.settings,
      label: "Settings",
      page: JoinAsTeamScreen(),
      notificationCount: 0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    if (index == _currentIndex) {
      // Optional: scroll to top or refresh current page
      return;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !Navigator.of(context).canPop(),
      child: Scaffold(
        body: PageTransitionSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _navItems[_currentIndex].page,
        ),
        bottomNavigationBar: _buildBottomNavBar(),
        floatingActionButton: _buildFAB(),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1976D2),
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        onTap: _onNavItemTapped,
        items: _navItems
            .asMap()
            .entries
            .map((entry) => _buildNavItem(entry.key, entry.value))
            .toList(),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(int index, _NavItem item) {
    return BottomNavigationBarItem(
      icon: Badge(
        isLabelVisible: item.notificationCount > 0,
        label: Text(
          item.notificationCount > 99
              ? '99+'
              : item.notificationCount.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red,
        child: Icon(item.icon),
      ),
      activeIcon: _buildActiveIcon(item.icon),
      label: item.label,
    );
  }

  Widget _buildActiveIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF1976D2).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon),
    );
  }

  Widget _buildFAB() {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
      ),
      child: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Action button pressed!')),
          );
        },
        backgroundColor: const Color(0xFF1976D2),
        elevation: 8,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final Widget page;
  final int notificationCount;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.page,
    this.notificationCount = 0,
  });
}

/// Custom page transition widget for smooth switching
class PageTransitionSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final AnimatedSwitcherTransitionBuilder transitionBuilder;

  const PageTransitionSwitcher({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    required this.transitionBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: transitionBuilder,
      child: child,
    );
  }
}