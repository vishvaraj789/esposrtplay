import 'package:flutter/material.dart';
import 'team_profiles_screen.dart';
import '../../models/player.dart';
import 'player_profiles_screen.dart';

// Color Scheme
const bgColor = Color(0xFF0B0B10);
const surfaceColor = Color(0xFF17171F);
const accentColor = Color(0xFF8B5CF6);
const accentSecondary = Color(0xFFFF7A45);
const textColor = Colors.white;
const textSecondaryColor = Color(0xFF9797A8);

class JoinAsPlayerForm extends StatefulWidget {
  const JoinAsPlayerForm({super.key});

  @override
  State<JoinAsPlayerForm> createState() => _JoinAsPlayerFormState();
}

class _JoinAsPlayerFormState extends State<JoinAsPlayerForm> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  late TextEditingController _fullNameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _playerUidController;
  late TextEditingController _ageController;
  late TextEditingController _bioController;
  late TextEditingController _mainGameController;
  late TextEditingController _locationController;

  // Dropdown selections
  String? _selectedRole;
  String? _selectedGameMode;
  bool _agreeToTerms = false;

  static const List<String> roles = [
    "Rusher",
    "Secondary Rusher",
    "Sniper",
    "Support",
    "Grenadier/IGL",
    "Nader"
  ];

  static const List<String> gameModes = [
    "Team Ranked",
    "Solo Queue",
    "Duo Queue",
    "Squad",
    "Tournament",
  ];


  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _playerUidController = TextEditingController();
    _ageController = TextEditingController();
    _bioController = TextEditingController();
    _mainGameController = TextEditingController();
    _locationController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _playerUidController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    _mainGameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please agree to terms and conditions"),
            backgroundColor: Color(0xFFFF5252),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Form is valid and terms agreed - submit data
      final playerData = PlayerData(
        username: _usernameController.text,
        phone: _phoneController.text,
        playerUid: _playerUidController.text,
        age: _ageController.text,
        location: _locationController.text,
        bio: _bioController.text,
        role: _selectedRole!,
        gameMode: _selectedGameMode!,
      );

      print(playerData.username);
      print(playerData.playerUid);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration successful!"),
          backgroundColor: Color(0xFF00E676),
          duration: Duration(seconds: 1),
        ),
      );

      // Navigate to TeamProfilesScreen after form submission
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlayerProfilesScreen(
                playerData: playerData,
              ),
            ),
          );
        }
      });
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
          "Join as Player",
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personal Information Section
              _buildSectionHeader("Personal Information"),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _usernameController,
                label: "Username",
                hint: "your_username",
                icon: Icons.account_circle,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Username is required";
                  }
                  if (value.length < 4) {
                    return "Username must be at least 4 characters";
                  }
                  if (!RegExp(r'^[a-zA-Z0-9_]*$').hasMatch(value)) {
                    return "Username can only contain letters, numbers, and underscore";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _phoneController,
                label: "Phone Number",
                hint: "+91 98765 43210",
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Phone number is required";
                  }
                  if (value.length < 10) {
                    return "Enter a valid phone number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _ageController,
                label: "Age",
                hint: "18",
                icon: Icons.cake,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Age is required";
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 13) {
                    return "You must be at least 13 years old";
                  }
                  if (age > 120) {
                    return "Enter a valid age";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _locationController,
                label: "Location / City",
                hint: "Ahmedabad, India",
                icon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Location is required";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 28),

              // Gaming Information Section
              _buildSectionHeader("Gaming Information"),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _playerUidController,
                label: "Player UID / ID",
                hint: "12345678",
                icon: Icons.badge,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Player UID is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                label: "Player Role",
                value: _selectedRole,
                items: roles,
                icon: Icons.stars,
                onChanged: (value) {
                  setState(() => _selectedRole = value);
                },
                validator: (_) {
                  if (_selectedRole == null) {
                    return "Please select a role";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                label: "Preferred Game Mode",
                value: _selectedGameMode,
                items: gameModes,
                icon: Icons.videogame_asset,
                onChanged: (value) {
                  setState(() => _selectedGameMode = value);
                },
                validator: (_) {
                  if (_selectedGameMode == null) {
                    return "Please select game mode";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 28),

              // Bio Section
              _buildSectionHeader("About You"),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _bioController,
                label: "Bio / Description",
                hint: "Tell us about yourself, achievements, playstyle...",
                icon: Icons.description,
                maxLines: 4,
                validator: (value) {
                  if (value != null && value.length > 500) {
                    return "Bio must be less than 500 characters";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 28),

              // Terms & Conditions
              _buildTermsCheckbox(),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Join as Player",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
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
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: textColor),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: textSecondaryColor),
        hintStyle: const TextStyle(color: textSecondaryColor),
        prefixIcon: Icon(icon, color: accentColor),
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF5252)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF5252), width: 1.5),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF5252), fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      validator: validator,
      style: const TextStyle(color: textColor),
      dropdownColor: surfaceColor,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: textSecondaryColor),
        prefixIcon: Icon(icon, color: accentColor),
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF5252)),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
      onChanged: onChanged,
      items: items
          .map((item) => DropdownMenuItem(
        value: item,
        child: Text(item, style: const TextStyle(color: textColor)),
      ))
          .toList(),
    );
  }

  Widget _buildTermsCheckbox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: _agreeToTerms,
            onChanged: (value) {
              setState(() => _agreeToTerms = value ?? false);
            },
            activeColor: accentColor,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
              child: const Text(
                "I agree to Terms & Conditions and Privacy Policy",
                style: TextStyle(
                  color: textSecondaryColor,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}