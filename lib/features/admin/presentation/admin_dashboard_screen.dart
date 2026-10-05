import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../routes/route_names.dart';
import '../../auth/provider/auth_provider.dart';
import '../models/admin_stats_model.dart';
import '../provider/admin_provider.dart';
import '../widgets/admin_action_button.dart';
import '../widgets/announcement_card.dart';

const _kCard = Color(0xFF171821);
const _kHairline = Color(0xFF2A2C38);
const _kTextSecondary = Color(0xFF9CA0AF);

const _kGreen = Color(0xFF3DDC84);
const _kAmber = Color(0xFFFFC24B);
const _kBlue = Color(0xFF3DA9FC);
const _kRed = Color(0xFFFF3D5A);

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: 'Logout',
      message: 'Are you sure you want to log out of the admin panel?',
      confirmText: 'Logout',
      isDanger: true,
    );
    if (confirmed != true || !context.mounted) return;

    // Grab these before the await: after sign-out this screen is removed.
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      await ref.read(authRepositoryProvider).signOut();
      router.go(Routes.login);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Logout failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final activityAsync = ref.watch(recentActivityProvider);
    final announcementsAsync = ref.watch(announcementsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(recentActivityProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Welcome Back',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text('Admin • EsportPlay', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            const SizedBox(height: 20),

            // ---- Overview + tournament status -------------------------------
            statsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator(color: AppColors.secondary)),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text("Couldn't load stats: $e", style: const TextStyle(color: Colors.redAccent)),
              ),
              data: (stats) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle('Overview'),
                  _StatRow(children: [
                    _MiniStat(label: 'Players', value: stats.totalPlayers, icon: Icons.person, color: _kBlue),
                    _MiniStat(label: 'Teams', value: stats.totalTeams, icon: Icons.groups, color: _kGreen),
                    _MiniStat(
                        label: 'Tournaments',
                        value: stats.totalTournaments,
                        icon: Icons.emoji_events,
                        color: AppColors.secondary),
                  ]),
                  const SizedBox(height: 12),
                  _StatRow(children: [
                    _MiniStat(label: 'Live', value: stats.liveTournaments, icon: Icons.sensors, color: _kRed),
                    _MiniStat(
                        label: 'Upcoming', value: stats.upcomingTournaments, icon: Icons.schedule, color: _kAmber),
                    _MiniStat(
                        label: 'Completed',
                        value: stats.completedTournaments,
                        icon: Icons.check_circle_outline,
                        color: _kGreen),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ---- Recent activity ---------------------------------------------
            const _SectionTitle('Recent Activity'),
            activityAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator(color: AppColors.secondary)),
              ),
              error: (e, _) => Text("Couldn't load activity: $e", style: const TextStyle(color: Colors.redAccent)),
              data: (items) {
                if (items.isEmpty) {
                  return Text('No recent activity', style: TextStyle(color: Colors.grey[500], fontSize: 13));
                }
                return Column(children: items.map((a) => _ActivityTile(activity: a)).toList());
              },
            ),
            const SizedBox(height: 28),

            // ---- Quick actions ------------------------------------------------
            const _SectionTitle('Quick Actions'),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                AdminActionButton(
                  label: 'Create Tournament',
                  icon: Icons.add_circle_outline,
                  color: AppColors.primary,
                  onTap: () => context.push(Routes.adminTournamentEditPath('new')),
                ),
                AdminActionButton(
                  label: 'Manage Teams',
                  icon: Icons.groups_outlined,
                  color: _kGreen,
                  onTap: () => context.push(Routes.adminTeams),
                ),
                AdminActionButton(
                  label: 'Manage Matches',
                  icon: Icons.sports_esports_outlined,
                  color: _kAmber,
                  onTap: () => context.push(Routes.adminMatches),
                ),
                AdminActionButton(
                  label: 'Announcements',
                  icon: Icons.campaign_outlined,
                  color: _kBlue,
                  onTap: () => context.push(Routes.adminAnnouncements),
                ),
                AdminActionButton(
                  label: 'Manage Players',
                  icon: Icons.people_outline,
                  color: AppColors.secondary,
                  onTap: () => context.push(Routes.adminPlayers),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ---- Announcements ------------------------------------------------
            const _SectionTitle('Recent Announcements'),
            announcementsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator(color: AppColors.secondary)),
              ),
              error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.redAccent)),
              data: (announcements) {
                if (announcements.isEmpty) {
                  return Text('No announcements yet', style: TextStyle(color: Colors.grey[500], fontSize: 13));
                }
                return Column(
                  children: announcements.take(3).map((a) => AnnouncementCard(announcement: a)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
  );
}

/// Three equal-width cards in one row.
class _StatRow extends StatelessWidget {
  final List<Widget> children;
  const _StatRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: AspectRatio(aspectRatio: 1.0, child: children[i])),
        ],
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _MiniStat({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kHairline),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('$value',
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label, style: const TextStyle(color: _kTextSecondary, fontSize: 11.5)),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final AdminActivity activity;
  const _ActivityTile({required this.activity});

  (IconData, Color) get _style => switch (activity.type) {
    AdminActivityType.player => (Icons.person_add_alt_1, _kBlue),
    AdminActivityType.team => (Icons.groups, _kGreen),
    AdminActivityType.tournament => (Icons.emoji_events, _kAmber),
  };

  static String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _style;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kHairline),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color.withOpacity(0.16), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.title,
                    style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(activity.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _kTextSecondary, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(_timeAgo(activity.time), style: const TextStyle(color: _kTextSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}