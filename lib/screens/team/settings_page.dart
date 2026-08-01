import 'package:flutter/material.dart';

// Color Scheme
const bgColor = Color(0xFF0B0B10);
const surfaceColor = Color(0xFF17171F);
const accentColor = Color(0xFF8B5CF6);
const accentSecondary = Color(0xFFFF7A45);
const textColor = Colors.white;
const textSecondaryColor = Color(0xFF9797A8);

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  bool _soundEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        title: const Text(
          "Settings",
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Section
          _buildSectionHeader("Account"),
          const SizedBox(height: 12),
          _buildSettingItem(
            "Username",
            "Player One",
            Icons.person_rounded,
                () {},
          ),
          _buildSettingItem(
            "Email",
            "player@esportplay.com",
            Icons.email_rounded,
                () {},
          ),
          const SizedBox(height: 24),

          // Preferences Section
          _buildSectionHeader("Preferences"),
          const SizedBox(height: 12),
          _buildSettingToggle(
            "Push Notifications",
            "Get tournament updates",
            Icons.notifications_rounded,
            _notificationsEnabled,
                (value) {
              setState(() => _notificationsEnabled = value);
            },
          ),
          _buildSettingToggle(
            "Dark Mode",
            "Always enabled",
            Icons.dark_mode_rounded,
            _darkModeEnabled,
                (value) {
              setState(() => _darkModeEnabled = value);
            },
          ),
          _buildSettingToggle(
            "Sound Effects",
            "Enable game sounds",
            Icons.volume_up_rounded,
            _soundEnabled,
                (value) {
              setState(() => _soundEnabled = value);
            },
          ),
          const SizedBox(height: 24),

          // Game Settings Section
          _buildSectionHeader("Game Settings"),
          const SizedBox(height: 12),
          _buildSettingItem(
            "Graphics Quality",
            "High",
            Icons.high_quality_rounded,
                () {},
          ),
          _buildSettingItem(
            "Language",
            "English",
            Icons.language_rounded,
                () {},
          ),
          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader("About"),
          const SizedBox(height: 12),
          _buildSettingItem(
            "Version",
            "1.0.0",
            Icons.info_rounded,
            null,
          ),
          _buildSettingItem(
            "Privacy Policy",
            "Read our policy",
            Icons.privacy_tip_rounded,
                () {},
          ),
          _buildSettingItem(
            "Terms of Service",
            "Read terms",
            Icons.description_rounded,
                () {},
          ),
          const SizedBox(height: 24),

          // Logout Button
          ElevatedButton(
            onPressed: () {
              _showLogoutDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Logout",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
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
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSettingItem(
      String title,
      String subtitle,
      IconData icon,
      VoidCallback? onTap,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
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
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
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
                if (onTap != null)
                  const Icon(Icons.chevron_right, color: textSecondaryColor, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingToggle(
      String title,
      String subtitle,
      IconData icon,
      bool value,
      Function(bool) onChanged,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
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
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
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
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: accentColor,
              inactiveTrackColor: Colors.grey.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        title: const Text(
          "Logout?",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to logout?",
          style: TextStyle(color: textSecondaryColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: accentColor),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Logged out successfully"),
                  backgroundColor: Color(0xFF00E676),
                ),
              );
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: Color(0xFFFF5252)),
            ),
          ),
        ],
      ),
    );
  }
}