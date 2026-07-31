import 'package:flutter/material.dart';
import '../../data/player_data.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/achievement.dart';
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isChanged = false;

  void checkChanges() {
    setState(() {
      isChanged =
          nameController.text.trim() != player.name ||
              emailController.text.trim() != player.email ||
              countryController.text.trim() != player.country ||
              teamController.text.trim() != player.team ||
              weaponController.text.trim() != player.favoriteWeapon ||
              mapController.text.trim() != player.favoriteMap ||
              modeController.text.trim() != player.favoriteMode ||
              bioController.text.trim() != player.bio;
    });
  }

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController countryController;
  late TextEditingController teamController;
  late TextEditingController weaponController;
  late TextEditingController mapController;
  late TextEditingController modeController;
  late TextEditingController bioController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: player.name);
    emailController = TextEditingController(text: player.email);
    countryController = TextEditingController(text: player.country);
    teamController = TextEditingController(text: player.team);
    weaponController = TextEditingController(text: player.favoriteWeapon);
    mapController = TextEditingController(text: player.favoriteMap);
    modeController = TextEditingController(text: player.favoriteMode);
    bioController = TextEditingController(text: player.bio);

    nameController.addListener(checkChanges);
    emailController.addListener(checkChanges);
    countryController.addListener(checkChanges);
    teamController.addListener(checkChanges);
    weaponController.addListener(checkChanges);
    mapController.addListener(checkChanges);
    modeController.addListener(checkChanges);
    bioController.addListener(checkChanges);
  }

  @override
  void dispose() {
    nameController.removeListener(checkChanges);
    emailController.removeListener(checkChanges);
    countryController.removeListener(checkChanges);
    teamController.removeListener(checkChanges);
    weaponController.removeListener(checkChanges);
    mapController.removeListener(checkChanges);
    modeController.removeListener(checkChanges);
    bioController.removeListener(checkChanges);

    nameController.dispose();
    emailController.dispose();
    countryController.dispose();
    teamController.dispose();
    weaponController.dispose();
    mapController.dispose();
    modeController.dispose();
    bioController.dispose();

    super.dispose();
  }

  void saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Save Changes"),
          content: const Text(
            "Are you sure you want to update your profile?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      player.name = nameController.text.trim();
      player.email = emailController.text.trim();
      player.country = countryController.text.trim();
      player.team = teamController.text.trim();
      player.favoriteWeapon = weaponController.text.trim();
      player.favoriteMap = mapController.text.trim();
      player.favoriteMode = modeController.text.trim();
      player.bio = bioController.text.trim();

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              CustomTextField(
                controller: nameController,
                label: "Player Name",
                hint: "Enter Name",
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Player name is required";
                  }

                  if (value.length < 3) {
                    return "Minimum 3 characters required";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              CustomTextField(
                controller: emailController,
                label: "Email",
                hint: "Enter Email",
                icon: Icons.email,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email is required";
                  }

                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );

                  if (!emailRegex.hasMatch(value)) {
                    return "Enter a valid email";
                  }

                  return null;
                },
              ),
              const SizedBox(height: 15),

              CustomTextField(
                controller: countryController,
                label: "Country",
                hint: "Enter Country",
                icon: Icons.flag,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Country is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),

              CustomTextField(
                controller: teamController,
                label: "Team",
                hint: "Enter Team Name",
                icon: Icons.groups,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Team name is required";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              CustomTextField(
                controller: weaponController,
                label: "Favorite Weapon",
                hint: "Enter Weapon",
                icon: Icons.security,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Favorite weapon is required";
                  }

                  return null;
                },

              ),

              const SizedBox(height: 15),

              CustomTextField(
                controller: mapController,
                label: "Favorite Map",
                hint: "Enter Map",
                icon: Icons.map,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Favorite map is required";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              CustomTextField(
                controller: modeController,
                label: "Favorite Mode",
                hint: "Enter Mode",
                icon: Icons.sports_esports,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Favorite mode is required";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: bioController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Bio",
                  hintText: "Tell us about yourself...",
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Bio is required";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: "Save Changes",
                  icon: Icons.save,
                  onPressed: isChanged ? saveProfile : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}