import 'package:flutter/material.dart';
import '../tournament/tournament_screen.dart';
import 'my_team_page.dart';
import 'settings_page.dart';

// Color Scheme
const bgColor = Color(0xFF0B0B10);
const surfaceColor = Color(0xFF17171F);
const accentColor = Color(0xFF8B5CF6);
const accentSecondary = Color(0xFFFF7A45);
const textColor = Colors.white;
const textSecondaryColor = Color(0xFF9797A8);

// Gradients
const heroGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF7C3AED), Color(0xFFC026D3), Color(0xFFFF7A45)],
);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Top Bar
            _buildTopBar(),
            const SizedBox(height: 20),

            // Welcome Banner
            _buildWelcomeBanner(),
            const SizedBox(height: 30),

            // Section: Quick Actions
            _buildSectionHeader("Quick Actions"),
            const SizedBox(height: 12),
            _buildQuickActions(),
            const SizedBox(height: 30),

            // Section: Featured Tournament
            _buildSectionHeader("Live Tournament"),
            const SizedBox(height: 12),
            _buildTournamentCard(),

            const SizedBox(height: 30),

            // Section: News
            _buildSectionHeader("Latest News"),
            const SizedBox(height: 12),
            _buildNewsCard("New Season Starts", "Registration open now", Icons.star),
            const SizedBox(height: 10),
            _buildNewsCard("Game Update", "New features added", Icons.update),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Top Bar with Profile & Icons
  Widget _buildTopBar() {
    return Row(
      children: [
        // Avatar
        Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: heroGradient,
          ),
          child: const Icon(Icons.person, color: textColor),
        ),
        const SizedBox(width: 12),

        // User Info
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Good Evening",
                style: TextStyle(color: textSecondaryColor, fontSize: 12),
              ),
              Text(
                "Player One",
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Icons
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search, color: textColor),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications, color: textColor),
        ),
      ],
    );
  }

  // Welcome Banner
  Widget _buildWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: heroGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Welcome to\nEsportPlay",
            style: TextStyle(
              color: textColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Play • Compete • Win",
            style: TextStyle(
              color: Color(0xFFCCCCCC),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: textColor,
                    foregroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Explore",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.play_arrow, color: textColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Section Header
  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            "View All",
            style: TextStyle(color: accentColor, fontSize: 12),
          ),
        ),
      ],
    );
  }

  // Quick Actions Grid
  Widget _buildQuickActions() {
    final actions = [
      ("Tournament", Icons.emoji_events, accentSecondary),
      ("Teams", Icons.groups, const Color(0xFF448AFF)),
      ("Profile", Icons.person, const Color(0xFF00E676)),
      ("Settings", Icons.settings, const Color(0xFFBA68C8)),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final (title, icon, color) = actions[index];
        return _buildActionCard(context, title, icon, color);
      },
    );
  }
  Widget _buildActionCard(
      BuildContext context,
      String title,
      IconData icon,
      Color color) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleActionTap(context, title),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleActionTap(BuildContext context, String title) {
    switch (title) {
      case "Tournament":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TournamentScreen()),
        );
        break;
      case "Teams":
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyTeamPage()));
      case "Settings":
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsPage()));
      default:
      // Teams / Profile / Settings screens not built yet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$title screen coming soon")),
        );
    }
  }
  // Tournament Card
  Widget _buildTournamentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: heroGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.emoji_events, color: textColor, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Free Fire Squad Clash",
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      "Squad • 128 Teams",
                      style: TextStyle(
                        color: textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Open",
                  style: TextStyle(
                    color: Color(0xFF00E676),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.72,
              minHeight: 6,
              backgroundColor: surfaceColor,
              valueColor: const AlwaysStoppedAnimation(accentSecondary),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "92 / 128 Teams Registered",
            style: TextStyle(color: textSecondaryColor, fontSize: 12),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Join Tournament",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // News Card
  Widget _buildNewsCard(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: textSecondaryColor, size: 18),
        ],
      ),
    );
  }
}