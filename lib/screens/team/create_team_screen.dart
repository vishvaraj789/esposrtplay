import 'package:flutter/material.dart';
import '../../data/team_repository.dart';
import '../../models/team.dart';
import 'member_details_form_screen.dart';

class CreateTeamScreen extends StatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _teamLogoPath;

  void _pickTeamLogo() {
    // Image Picker will be added later.
    // For now, just show a message.

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Image Picker will be added later."),
      ),
    );
  }

  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _teamTagController = TextEditingController();
  final TextEditingController _teamDescriptionController =
  TextEditingController();

  @override
  void dispose() {
    _teamNameController.dispose();
    _teamTagController.dispose();
    _teamDescriptionController.dispose();
    super.dispose();
  }

  String _selectedRegion = "India";
  String _selectedLanguage = "English";
  String _selectedRank = "Bronze";
  String _selectedTeamType = "Competitive";

  final List<String> _regions = [
    "India",
    "Nepal",
    "Bangladesh",
    "Sri Lanka",
    "Pakistan",
  ];

  final List<String> _languages = [
    "English",
    "Hindi",
    "Gujarati",
    "Tamil",
    "Telugu",
  ];

  final List<String> _ranks = [
    "Bronze",
    "Silver",
    "Gold",
    "Platinum",
    "Diamond",
    "Heroic",
    "Master",
  ];

  final List<String> _teamTypes = [
    "Casual",
    "Competitive",
    "Professional",
  ];

  bool _isRecruiting = true;
  bool _agreeTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      appBar: AppBar(
        title: const Text("Create Team"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Page Heading
                const Center(
                  child: Text(
                    "Build Your Esports Team",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                const Center(
                  child: Text(
                    "Fill in the details below to create your team.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// ==========================
                /// Team Logo Section
                /// ==========================
                _sectionTitle("Team Logo"),
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickTeamLogo,
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.white10,
                          backgroundImage: _teamLogoPath != null
                              ? AssetImage(_teamLogoPath!)
                              : null,
                          child: _teamLogoPath == null
                              ? const Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.orange,
                          )
                              : null,
                        ),
                      ),

                      const SizedBox(height: 15),

                      ElevatedButton.icon(
                        onPressed: _pickTeamLogo,
                        icon: const Icon(Icons.upload),
                        label: const Text("Upload Team Logo"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Recommended: 512 × 512 PNG or JPG",
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(height: 5),

                      const Text(
                        "Maximum file size: 5 MB",
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// ==========================
                /// Team Information
                /// ==========================
                _sectionTitle("Team Information"),

                const SizedBox(height: 10),

                Column(
                  children: [

                    /// Team Name
                    TextFormField(
                      controller: _teamNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Team Name",
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintText: "Enter your team name",
                        hintStyle: const TextStyle(color: Colors.white38),
                        prefixIcon: const Icon(Icons.groups, color: Colors.orange),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter your team name";
                        }

                        if (value.trim().length < 3) {
                          return "Team name must be at least 3 characters";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    /// Team Tag
                    TextFormField(
                      controller: _teamTagController,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 5,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Team Tag",
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintText: "Example: ESP",
                        hintStyle: const TextStyle(color: Colors.white38),
                        prefixIcon: const Icon(Icons.tag, color: Colors.orange),
                        counterStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter a team tag";
                        }

                        if (value.trim().length < 2) {
                          return "Minimum 2 characters";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    /// Team Description
                    TextFormField(
                      controller: _teamDescriptionController,
                      maxLines: 5,
                      maxLength: 200,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Team Description",
                        labelStyle: const TextStyle(color: Colors.white70),
                        hintText:
                        "Tell players about your team, goals, play style, and recruitment...",
                        hintStyle: const TextStyle(color: Colors.white38),
                        alignLabelWithHint: true,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 90),
                          child: Icon(Icons.description, color: Colors.orange),
                        ),
                        counterStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter a team description";
                        }

                        if (value.trim().length < 20) {
                          return "Description should be at least 20 characters";
                        }

                        return null;
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                /// ==========================
                /// Game Details
                /// ==========================
                _sectionTitle("Game Details"),

                const SizedBox(height: 10),

                Column(
                  children: [

                    DropdownButtonFormField<String>(
                      value: _selectedRegion,
                      dropdownColor: const Color(0xFF1E1E1E),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Region",
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.public, color: Colors.orange),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: _regions.map((region) {
                        return DropdownMenuItem(
                          value: region,
                          child: Text(region),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRegion = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      value: _selectedLanguage,
                      dropdownColor: const Color(0xFF1E1E1E),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Language",
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.language, color: Colors.orange),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: _languages.map((language) {
                        return DropdownMenuItem(
                          value: language,
                          child: Text(language),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedLanguage = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      value: _selectedRank,
                      dropdownColor: const Color(0xFF1E1E1E),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Team Rank",
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.emoji_events, color: Colors.orange),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: _ranks.map((rank) {
                        return DropdownMenuItem(
                          value: rank,
                          child: Text(rank),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRank = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      value: _selectedTeamType,
                      dropdownColor: const Color(0xFF1E1E1E),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Team Type",
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.sports_esports, color: Colors.orange),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: _teamTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTeamType = value!;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                /// ==========================
                /// Settings
                /// ==========================
                _sectionTitle("Settings"),

                const SizedBox(height: 10),

                Card(
                  color: Colors.white10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [

                        SwitchListTile(
                          value: _isRecruiting,
                          activeColor: Colors.orange,
                          title: const Text(
                            "Recruiting Players",
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: const Text(
                            "Allow players to send join requests.",
                            style: TextStyle(color: Colors.white60),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _isRecruiting = value;
                            });
                          },
                        ),

                        const Divider(color: Colors.white24),

                        CheckboxListTile(
                          value: _agreeTerms,
                          activeColor: Colors.orange,
                          checkColor: Colors.white,
                          title: const Text(
                            "I agree to the Terms & Conditions",
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: const Text(
                            "You must accept before creating your team.",
                            style: TextStyle(color: Colors.white60),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _agreeTerms = value ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                /// ==========================
                /// Create Team Button
                /// ==========================
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {

                      Team newTeam = Team(
                        teamName: _teamNameController.text.trim(),
                        teamLogo: _teamLogoPath ?? "",
                        members: [],
                      );


                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),

                    child: const Text(
                      "Create Team",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.orange,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}