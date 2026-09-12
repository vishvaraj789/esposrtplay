import 'package:characters/characters.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/services/user_service.dart';

/// User profile, match history, settings, and logout.
/// Reads the current user's profile document live from Firestore.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    // Simple loading indicator while signing out.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Sign out of Firebase Auth (ends the app session) AND GoogleSignIn
      // (clears the cached Google account). Without the second call, the
      // GoogleSignIn plugin keeps a silent session cached on-device, so a
      // future "Continue with Google" tap can skip the account picker
      // entirely or default back to whichever account was used last —
      // which looks like "it's remembering all my emails."
      await Future.wait([
        FirebaseAuth.instance.signOut(),
        GoogleSignIn.instance.signOut(),
      ]);

      if (!context.mounted) return;
      Navigator.of(context).pop(); // close loading dialog

      // Replaces the entire navigation stack so the user can't
      // press "back" and return to a logged-in screen.
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text('Logout failed: ${e.message}'),
        ),
      );
    }
  }

  String _initials(String nickname) {
    final trimmed = nickname.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: uid == null
          ? const Center(child: Text('Not signed in'))
          : StreamBuilder<Map<String, dynamic>?>(
        stream: UserService.instance.watchUserProfile(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                    const SizedBox(height: 12),
                    Text('Something went wrong.\n${snapshot.error}',
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }

          final profile = snapshot.data;
          final nickname = profile?['nickname'] as String? ?? 'Player';
          final fullName = profile?['fullName'] as String? ?? '';
          final role = profile?['role'] as String? ?? '';
          final freeFireUid = profile?['freeFireUid'] as String? ?? '';

          return CustomScrollView(
            slivers: [
              // Gradient header with avatar, name and role.
              SliverAppBar(
                pinned: true,
                stretch: true,
                expandedHeight: 260,
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  titlePadding: const EdgeInsets.only(bottom: 16),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withValues(alpha: 0.75),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: CircleAvatar(
                              radius: 42,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              child: Text(
                                _initials(nickname),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            nickname,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (fullName.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              fullName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                          if (role.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Chip(
                              label: Text(
                                role,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: Colors.white.withValues(alpha: 0.18),
                              side: BorderSide.none,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Content below the header.
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (freeFireUid.isNotEmpty) ...[
                      _SectionCard(
                        children: [
                          _ProfileTile(
                            icon: Icons.badge_outlined,
                            iconColor: colorScheme.primary,
                            title: 'Free Fire MAX UID',
                            subtitle: freeFireUid,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    _SectionCard(
                      children: [
                        _ProfileTile(
                          icon: Icons.history,
                          iconColor: colorScheme.primary,
                          title: 'Match History',
                          onTap: () {
                            // TODO: navigate to match history screen.
                          },
                        ),
                        const Divider(height: 1, indent: 56),
                        _ProfileTile(
                          icon: Icons.settings_outlined,
                          iconColor: colorScheme.primary,
                          title: 'Settings',
                          onTap: () {
                            // TODO: navigate to settings screen.
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _confirmLogout(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text(
                          'Logout',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// A rounded, elevated container that groups related [_ProfileTile]s.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

/// A single row inside a [_SectionCard], with a tinted icon chip.
class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: onTap != null
          ? const Icon(Icons.chevron_right, size: 20)
          : null,
    );
  }
}