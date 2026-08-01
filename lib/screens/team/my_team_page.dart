import 'package:flutter/material.dart';

import '../../data/player_data.dart';
import '../../data/team_data.dart';
import '../../models/team.dart';
import '../../models/team_member.dart';
import '../player/edit_profile_screen.dart';

// Color Scheme
const bgColor = Color(0xFF0B0B10);
const surfaceColor = Color(0xFF17171F);
const accentColor = Color(0xFF8B5CF6);
const accentSecondary = Color(0xFFFF7A45);
const textColor = Colors.white;
const textSecondaryColor = Color(0xFF9797A8);

// Colors cycled through for teammates other than the current user.
const List<Color> _memberColors = [
  accentSecondary,
  Color(0xFF448AFF),
  Color(0xFF00E676),
  Color(0xFFFFD166),
];

class MyTeamPage extends StatefulWidget {
  const MyTeamPage({super.key});

  @override
  State<MyTeamPage> createState() => _MyTeamPageState();
}

class _MyTeamPageState extends State<MyTeamPage> {
  late Team _team;

  @override
  void initState() {
    super.initState();
    // Load the previously saved team (created via Create/Join Team flow).
    // If none exists yet, build one seeded with the logged-in user's data
    // so the page always reflects real user data instead of dummy text.
    _team = TeamData.getTeam() ?? _buildDefaultTeam();
    TeamData.saveTeam(_team);
  }

  Team _buildDefaultTeam() {
    return Team(
      teamName: player.team.trim().isNotEmpty ? player.team : "My Squad",
      teamLogo: "",
      members: [
        TeamMember(
          playerName: player.name,
          playerUid: player.uid,
          role: "Captain",
          isCaptain: true,
        ),
        TeamMember(
          playerName: "ShadowStrike",
          playerUid: "10293847",
          role: "Co-Captain",
        ),
        TeamMember(
          playerName: "NovaBlaze",
          playerUid: "48291037",
          role: "Member",
        ),
        TeamMember(
          playerName: "Phoenix_King",
          playerUid: "77281910",
          role: "Member",
        ),
      ],
    );
  }

  bool _isCurrentUser(TeamMember member) => member.playerUid == player.uid;

  String get _captainName {
    final captain = _team.members.where((m) => m.isCaptain).toList();
    if (captain.isNotEmpty) return captain.first.playerName;
    if (_team.members.isNotEmpty) return _team.members.first.playerName;
    return player.name;
  }

  String _formatNumber(int value) {
    final raw = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      final posFromEnd = raw.length - i;
      buffer.write(raw[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }

  void _saveTeam(Team updated) {
    setState(() {
      _team = updated;
      TeamData.saveTeam(_team);
    });
  }

  Future<void> _showEditTeamDialog() async {
    final nameController = TextEditingController(text: _team.teamName);

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: surfaceColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: const Text(
              "Edit Team",
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
            content: TextField(
              controller: nameController,
              autofocus: true,
              style: const TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: "Team Name",
                labelStyle: const TextStyle(color: textSecondaryColor),
                filled: true,
                fillColor: bgColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Cancel", style: TextStyle(color: textSecondaryColor)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: accentColor),
                onPressed: () {
                  final newName = nameController.text.trim();
                  if (newName.isNotEmpty) {
                    _saveTeam(_team.copyWith(teamName: newName));
                  }
                  Navigator.pop(dialogContext);
                },
                child: const Text("Save", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    } finally {
      nameController.dispose();
    }
  }

  Future<void> _showAddMemberDialog() async {
    final nameController = TextEditingController();
    final uidController = TextEditingController();

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: surfaceColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: const Text(
              "Add Member",
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  style: const TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: "Player Name",
                    labelStyle: const TextStyle(color: textSecondaryColor),
                    filled: true,
                    fillColor: bgColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: uidController,
                  style: const TextStyle(color: textColor),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Player UID",
                    labelStyle: const TextStyle(color: textSecondaryColor),
                    filled: true,
                    fillColor: bgColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Cancel", style: TextStyle(color: textSecondaryColor)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: accentColor),
                onPressed: () {
                  final name = nameController.text.trim();
                  final uid = uidController.text.trim();
                  if (name.isNotEmpty) {
                    final updatedMembers = List<TeamMember>.from(_team.members)
                      ..add(TeamMember(
                        playerName: name,
                        playerUid: uid.isEmpty ? '-' : uid,
                        role: "Member",
                      ));
                    _saveTeam(_team.copyWith(members: updatedMembers));
                  }
                  Navigator.pop(dialogContext);
                },
                child: const Text("Add", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
    } finally {
      nameController.dispose();
      uidController.dispose();
    }
  }

  Future<void> _editMyProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );

    if (!mounted) return;

    // Player data may have changed inside EditProfileScreen (name, etc.).
    // Sync the matching team member entry so the roster stays up to date.
    final index = _team.members.indexWhere(_isCurrentUser);
    if (index != -1) {
      final updatedMembers = List<TeamMember>.from(_team.members);
      updatedMembers[index] = updatedMembers[index].copyWith(
        playerName: player.name,
      );
      _saveTeam(_team.copyWith(members: updatedMembers));
    } else {
      setState(() {});
    }
  }

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
            onPressed: _showEditTeamDialog,
            tooltip: "Edit Team",
            icon: const Icon(Icons.edit_rounded, color: accentColor),
          ),
          IconButton(
            onPressed: _showAddMemberDialog,
            tooltip: "Add Member",
            icon: const Icon(Icons.add_rounded, color: accentColor),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Team Header (real team + user data)
          _buildTeamHeader(),
          const SizedBox(height: 20),

          // Team Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "${_team.members.length}",
                  "Members",
                  accentColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  _formatNumber(player.wins),
                  "Wins",
                  accentSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  player.rank,
                  "Rank",
                  const Color(0xFFFFD166),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Team Members Section
          _buildSectionHeader("Members"),
          const SizedBox(height: 12),
          ...List.generate(_team.members.length, (index) {
            final member = _team.members[index];
            final isMe = _isCurrentUser(member);
            final color = isMe
                ? accentColor
                : _memberColors[index % _memberColors.length];
            return _buildTeamMember(member, color, isMe);
          }),
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

  Widget _buildTeamHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: accentColor.withOpacity(0.2),
            child: const Icon(Icons.shield_rounded, color: accentColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _team.teamName,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Captain: $_captainName",
                  style: const TextStyle(
                    color: textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _showEditTeamDialog,
            tooltip: "Edit Team",
            icon: const Icon(Icons.edit_rounded, color: accentColor, size: 20),
          ),
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
    TeamMember member,
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
                  member.playerName,
                  style: const TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  member.role,
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
              margin: const EdgeInsets.only(right: 6),
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
          if (isMe)
            IconButton(
              onPressed: _editMyProfile,
              tooltip: "Edit Profile",
              icon: const Icon(Icons.edit_rounded, color: accentColor, size: 18),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
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
