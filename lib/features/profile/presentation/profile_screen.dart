import 'package:characters/characters.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../provider/profile_provider.dart';
import '../widgets/stats_card.dart';

/// User profile, match history, settings, and logout.
/// Reads the current user's profile live via currentUserProfileProvider.
class ProfileScreen extends ConsumerWidget {
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
      // entirely or default back to whichever account was used last.
      await Future.wait([
        FirebaseAuth.instance.signOut(),
        GoogleSignIn.instance.signOut(),
      ]);

      if (!context.mounted) return;
      Navigator.of(context).pop(); // close loading dialog

      // No manual navigation here — GoRouter's redirect (in app_router.dart)
      // reacts automatically once authStateChanges emits null and sends
      // the user to Routes.login. A manual Navigator.pushNamed call here
      // would use the old named-routes API, which this app no longer uses
      // now that it's on MaterialApp.router + GoRouter.
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                const SizedBox(height: 12),
                Text('Something went wrong.\n$e', textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Not signed in'));
          }

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
                              backgroundImage: profile.photoUrl != null
                                  ? NetworkImage(profile.photoUrl!)
                                  : null,
                              child: profile.photoUrl == null
                                  ? Text(
                                _initials(profile.nickname),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            profile.nickname,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (profile.fullName.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              profile.fullName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                          if (profile.role != null && profile.role!.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Chip(
                              label: Text(
                                profile.role!,
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
                    StatsCard(matches: profile.matches, wins: profile.wins, rank: profile.rank),
                    const SizedBox(height: 16),
                    if (profile.freeFireUid.isNotEmpty) ...[
                      _SectionCard(
                        children: [
                          _ProfileTile(
                            icon: Icons.badge_outlined,
                            iconColor: colorScheme.primary,
                            title: 'Free Fire MAX UID',
                            subtitle: profile.freeFireUid,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    _SectionCard(
                      children: [
                        _ProfileTile(
                          icon: Icons.edit_outlined,
                          iconColor: colorScheme.primary,
                          title: 'Edit Profile',
                          onTap: () {
                            // TODO: navigate to edit_profile_screen.dart once it's wired into app_router.dart.
                          },
                        ),
                        const Divider(height: 1, indent: 56),
                        _ProfileTile(
                          icon: Icons.emoji_events_outlined,
                          iconColor: colorScheme.primary,
                          title: 'Achievements',
                          onTap: () {
                            // TODO: navigate to achievements_screen.dart once it's wired into app_router.dart.
                          },
                        ),
                        const Divider(height: 1, indent: 56),
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