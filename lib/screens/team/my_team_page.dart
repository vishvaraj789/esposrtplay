import 'package:flutter/material.dart';

// Color Scheme
const bgColor = Color(0xFF0B0B10);
const surfaceColor = Color(0xFF17171F);
const accentColor = Color(0xFF8B5CF6);
const accentSecondary = Color(0xFFFF7A45);
const textColor = Colors.white;
const textSecondaryColor = Color(0xFF9797A8);

class MyTeamPage extends StatelessWidget {
  const MyTeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        title: const Text(
          "My Team",
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded, color: accentColor),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Team Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard("12", "Members", accentColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard("4,320", "Wins", accentSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard("#42", "Rank", const Color(0xFFFFD166)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Team Members Section
          _buildSectionHeader("Members"),
          const SizedBox(height: 12),
          _buildTeamMember("Captain", "You", accentColor, true),
          _buildTeamMember("Co-Captain", "ShadowStrike", accentSecondary, false),
          _buildTeamMember("Member", "NovaBlaze", const Color(0xFF448AFF), false),
          _buildTeamMember("Member", "Phoenix_King", const Color(0xFF00E676), false),
          const SizedBox(height: 24),

          // Tournaments Participated
          _buildSectionHeader("Recent Tournaments"),
          const SizedBox(height: 12),
          _buildTournamentHistory("Free Fire Squad Clash", "🥇 Winner", accentSecondary),
          _buildTournamentHistory("BGMI Team League", "🥈 2nd Place", const Color(0xFFC0C0C0)),
          _buildTournamentHistory("Valorant 5v5", "3rd Place", const Color(0xFFCD7F32)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: textSecondaryColor,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMember(
      String role,
      String name,
      Color color,
      bool isMe,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(Icons.person, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  role,
                  style: const TextStyle(
                    color: textSecondaryColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (isMe)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "You",
                style: TextStyle(color: accentColor, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTournamentHistory(String title, String result, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.emoji_events, color: color, size: 18),
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
                    fontSize: 13,
                  ),
                ),
                Text(
                  result,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}