import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'member_details_form_screen.dart';
import '../../core/widgets/custom_text_field.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';

class JoinAsTeamScreen extends StatefulWidget {
  const JoinAsTeamScreen({super.key});

  @override
  State<JoinAsTeamScreen> createState() => _JoinAsTeamScreenState();
}

class _JoinAsTeamScreenState extends State<JoinAsTeamScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController teamNameController =
  TextEditingController();

  final TextEditingController playerCountController =
  TextEditingController();

  final ImagePicker _picker = ImagePicker();

  File? _teamLogo;
  String? _teamLogoPath;

  @override
  void dispose() {
    teamNameController.dispose();
    playerCountController.dispose();
    super.dispose();
  }

  void _joinTeam() {
    if (_formKey.currentState!.validate()) {

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MemberDetailsFormScreen(
            playerCount: int.parse(playerCountController.text),
            teamName: teamNameController.text.trim(),
            teamLogoPath: _teamLogoPath,
          ),
        ),
      );
    }
  }
  Future<void> _pickTeamLogo() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _teamLogo = File(image.path);
        _teamLogoPath = image.path;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      appBar: AppBar(
        title: const Text("Join as Team"),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                const SizedBox(height: 20),

                const Icon(
                  Icons.sports_esports,
                  size: 90,
                  color: Colors.blue,
                ),

                const SizedBox(height: 20),

                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickTeamLogo,
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.white10,
                          backgroundImage:
                          _teamLogo != null ? FileImage(_teamLogo!) : null,
                          child: _teamLogo == null
                              ? const Icon(
                            Icons.camera_alt,
                            color: Colors.orange,
                            size: 40,
                          )
                              : null,
                        ),
                      ),

                      const SizedBox(height: 15),

                      ElevatedButton.icon(
                        onPressed: _pickTeamLogo,
                        icon: const Icon(Icons.upload),
                        label: const Text("Upload Team Logo"),
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


                CustomTextField(
                  controller: teamNameController,
                  label: "Team Name",
                  hint: "Enter team name",
                  icon: Icons.groups,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Team name is required";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: playerCountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    labelText: "How many players",
                    hintText: "Enter number of players",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.people),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter number of players";
                    }

                    final players = int.tryParse(value);

                    if (players == null || players <= 0) {
                      return "Enter a valid number";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 30),

                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _joinTeam,
                    icon: const Icon(Icons.login),
                    label: const Text(
                      "Enter",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}