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
  final Map<String, bool> _toggleSettings = {
    'notifications': true,
    'darkMode': true,
    'sound': true,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        title: const Text("Settings", style: _titleStyle),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            "Account",
            [
              _SettingItemModel("Username", "Player One", Icons.person_rounded),
              _SettingItemModel("Email", "player@esportplay.com", Icons.email_rounded),
            ],
          ),
          _buildSection(
            "Preferences",
            [
              _SettingToggleModel("Push Notifications", "Get tournament updates", Icons.notifications_rounded, 'notifications'),
              _SettingToggleModel("Dark Mode", "Always enabled", Icons.dark_mode_rounded, 'darkMode'),
              _SettingToggleModel("Sound Effects", "Enable game sounds", Icons.volume_up_rounded, 'sound'),
            ],
          ),
          _buildSection(
            "Game Settings",
            [
              _SettingItemModel("Graphics Quality", "High", Icons.high_quality_rounded),
              _SettingItemModel("Language", "English", Icons.language_rounded),
            ],
          ),
          _buildSection(
            "About",
            [
              _SettingItemModel("Version", "1.0.0", Icons.info_rounded, isClickable: false),
              _SettingItemModel("Privacy Policy", "Read our policy", Icons.privacy_tip_rounded),
              _SettingItemModel("Terms of Service", "Read terms", Icons.description_rounded),
            ],
          ),
          const SizedBox(height: 24),
          _buildLogoutButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _sectionHeaderStyle),
        const SizedBox(height: 12),
        ...items.map((item) => item is _SettingToggleModel
            ? _buildToggleItem(item)
            : _buildItem(item)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildItem(_SettingItemModel model) {
    return _SettingContainer(
      child: Row(
        children: [
          _buildIconBox(model.icon),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTextColumn(model.title, model.subtitle),
          ),
          if (model.isClickable) const Icon(Icons.chevron_right, color: textSecondaryColor, size: 18),
        ],
      ),
    );
  }

  Widget _buildToggleItem(_SettingToggleModel model) {
    return _SettingContainer(
      child: Row(
        children: [
          _buildIconBox(model.icon),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTextColumn(model.title, model.subtitle),
          ),
          Switch(
            value: _toggleSettings[model.key] ?? false,
            onChanged: (value) => setState(() => _toggleSettings[model.key] = value),
            activeColor: accentColor,
            inactiveTrackColor: Colors.grey.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildIconBox(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: accentColor, size: 18),
    );
  }

  Widget _buildTextColumn(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _itemTitleStyle),
        Text(subtitle, style: _itemSubtitleStyle),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      onPressed: () => _showLogoutDialog(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF5252),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text("Logout", style: _buttonTextStyle),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        title: const Text("Logout?", style: _dialogTitleStyle),
        content: const Text("Are you sure you want to logout?", style: _dialogTextStyle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: _accentTextStyle),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Logged out successfully"), backgroundColor: Color(0xFF00E676)),
              );
            },
            child: const Text("Logout", style: _errorTextStyle),
          ),
        ],
      ),
    );
  }

  // Text Styles
  static const _titleStyle = TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold);
  static const _sectionHeaderStyle = TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5);
  static const _itemTitleStyle = TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 14);
  static const _itemSubtitleStyle = TextStyle(color: textSecondaryColor, fontSize: 12);
  static const _buttonTextStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor);
  static const _dialogTitleStyle = TextStyle(color: textColor, fontWeight: FontWeight.bold);
  static const _dialogTextStyle = TextStyle(color: textSecondaryColor);
  static const _accentTextStyle = TextStyle(color: accentColor);
  static const _errorTextStyle = TextStyle(color: Color(0xFFFF5252));
}

class _SettingContainer extends StatelessWidget {
  final Widget child;
  const _SettingContainer({required this.child});

  @override
  Widget build(BuildContext context) {
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
          borderRadius: BorderRadius.circular(12),
          child: Padding(padding: const EdgeInsets.all(14), child: child),
        ),
      ),
    );
  }
}

class _SettingItemModel {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isClickable;

  _SettingItemModel(this.title, this.subtitle, this.icon, {this.isClickable = true});
}

class _SettingToggleModel {
  final String title;
  final String subtitle;
  final IconData icon;
  final String key;

  _SettingToggleModel(this.title, this.subtitle, this.icon, this.key);
}