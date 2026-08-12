import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/team_data.dart';
import '../../models/team.dart';
import '../../models/team_member.dart';

// Color Scheme
const bgColor = Color(0xFF0B0B10);
const surfaceColor = Color(0xFF17171F);
const accentColor = Color(0xFF8B5CF6);
const accentSecondary = Color(0xFFFF7A45);
const textColor = Colors.white;
const textSecondaryColor = Color(0xFF9797A8);

const List<Color> _memberColors = [
  accentSecondary,
  Color(0xFF448AFF),
  Color(0xFF00E676),
  Color(0xFFFFD166),
];

const List<String> _roles = [
  "Rusher",
  "Secondary Rusher",
  "Sniper",
  "Support",
  "Grenadier/IGL",
  "Nader"
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
    _team = TeamData.getTeam()!;
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
              "Edit Team Name",
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

  Future<void> _showEditMemberDialog(int index, TeamMember member) async {
    final nameController = TextEditingController(text: member.playerName);
    final uidController = TextEditingController(text: member.playerUid);
    String selectedRole = member.role;

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                backgroundColor: surfaceColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                title: const Text(
                  "Edit Member",
                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
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
                    const SizedBox(height: 12),
                    _buildRoleDropdown(selectedRole, (value) {
                      setDialogState(() => selectedRole = value);
                    }),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text("Cancel", style: TextStyle(color: textSecondaryColor)),
                  ),
                  TextButton(
                    onPressed: () {
                      _deleteMember(index);
                      Navigator.pop(dialogContext);
                    },
                    child: const Text("Delete", style: TextStyle(color: Color(0xFFFF5252))),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: accentColor),
                    onPressed: () {
                      final name = nameController.text.trim();
                      final uid = uidController.text.trim();
                      if (name.isNotEmpty) {
                        final updatedMembers = List<TeamMember>.from(_team.members);
                        updatedMembers[index] = member.copyWith(
                          playerName: name,
                          playerUid: uid.isEmpty ? '-' : uid,
                          role: selectedRole,
                          isCaptain: selectedRole == "Captain",
                        );
                        _saveTeam(_team.copyWith(members: updatedMembers));
                      }
                      Navigator.pop(dialogContext);
                    },
                    child: const Text("Save", style: TextStyle(color: Colors.white)),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      nameController.dispose();
      uidController.dispose();
    }
  }

  Future<void> _showAddMemberDialog() async {
    final nameController = TextEditingController();
    final uidController = TextEditingController();
    String selectedRole = _roles[2]; // Default to "Member"

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
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
                    const SizedBox(height: 12),
                    _buildRoleDropdown(selectedRole, (value) {
                      setDialogState(() => selectedRole = value);
                    }),
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
                            role: selectedRole,
                            isCaptain: selectedRole == "Captain",
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
        },
      );
    } finally {
      nameController.dispose();
      uidController.dispose();
    }
  }

  void _deleteMember(int index) {
    final updatedMembers = List<TeamMember>.from(_team.members)..removeAt(index);
    _saveTeam(_team.copyWith(members: updatedMembers));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Member removed"),
        backgroundColor: Color(0xFF00E676),
      ),
    );
  }

  Widget _buildRoleDropdown(String selectedRole, Function(String) onChanged) {
    // Ensure selectedRole exists in _roles, fallback to first role if not
    final validRole = _roles.contains(selectedRole) ? selectedRole : _roles[0];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButton<String>(
        value: validRole,
        isExpanded: true,
        underline: const SizedBox(),
        style: const TextStyle(color: textColor),
        dropdownColor: surfaceColor,
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
        items: _roles.map((role) {
          return DropdownMenuItem(
            value: role,
            child: Text(role),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final team = TeamData.getTeam();

    if (team == null) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: surfaceColor,
          elevation: 0,
          title: const Text(
            "Team Details",
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            "No Team Data Found",
            style: TextStyle(color: textSecondaryColor, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        title: Text(
          team.teamName,
          style: const TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showAddMemberDialog,
            tooltip: "Add Member",
            icon: const Icon(Icons.person_add_rounded, color: accentColor),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: _showEditTeamDialog,
              icon: const Icon(Icons.edit_rounded, size: 18),
              label: const Text("Edit"),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: const Size(64, 36),
                maximumSize: const Size(120, 40),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Team Logo
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(80),
                border: Border.all(color: accentColor, width: 2),
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: surfaceColor,
                backgroundImage: team.teamLogo.isNotEmpty
                    ? FileImage(File(team.teamLogo))
                    : null,
                child: team.teamLogo.isEmpty
                    ? const Icon(Icons.shield_rounded, color: accentColor, size: 40)
                    : null,
              ),
            ),

            const SizedBox(height: 24),

            // Team Name
            Text(
              team.teamName,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            // Member Count
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                "${team.members.length} Members",
                style: const TextStyle(
                  fontSize: 14,
                  color: textSecondaryColor,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Members List
            Expanded(
              child: ListView.builder(
                itemCount: team.members.length,
                itemBuilder: (context, index) {
                  final member = team.members[index];
                  final color = _memberColors[index % _memberColors.length];

                  return GestureDetector(
                    onTap: () => _showEditMemberDialog(index, member),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
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
                            radius: 22,
                            backgroundColor: color.withOpacity(0.2),
                            child: Text(
                              "${index + 1}",
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        member.playerName,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                    if (member.isCaptain)
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: accentSecondary.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          "Captain",
                                          style: TextStyle(
                                            color: accentSecondary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "UID: ${member.playerUid}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: textSecondaryColor,
                                      ),
                                    ),
                                    Text(
                                      "Role: ${member.role}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => _showEditMemberDialog(index, member),
                            icon: const Icon(Icons.edit_rounded, color: accentColor, size: 20),
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}