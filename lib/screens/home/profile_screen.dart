import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../service/user_service.dart';

/// User profile, match history, settings, and logout.
/// Reads the current user's profile document live from Firestore.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    try {
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;

      // Replaces the entire navigation stack so the user can't
      // press "back" and return to a logged-in screen.
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: uid == null
          ? const Center(child: Text('Not signed in'))
          : StreamBuilder<Map<String, dynamic>?>(
        stream: UserService.instance.watchUserProfile(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final profile = snapshot.data;
          final nickname = profile?['nickname'] as String? ?? 'Player';
          final fullName = profile?['fullName'] as String? ?? '';
          final role = profile?['role'] as String? ?? '';
          final freeFireUid = profile?['freeFireUid'] as String? ?? '';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const CircleAvatar(
                radius: 40,
                child: Icon(Icons.person, size: 40),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  nickname,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (fullName.isNotEmpty)
                Center(
                  child: Text(
                    fullName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              const SizedBox(height: 16),
              if (role.isNotEmpty)
                Center(
                  child: Chip(label: Text(role)),
                ),
              const SizedBox(height: 24),
              if (freeFireUid.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.badge),
                  title: const Text('Free Fire MAX UID'),
                  subtitle: Text(freeFireUid),
                ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Match History'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: navigate to match history screen.
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: navigate to settings screen.
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () => _confirmLogout(context),
              ),
            ],
          );
        },
      ),
    );
  }
}