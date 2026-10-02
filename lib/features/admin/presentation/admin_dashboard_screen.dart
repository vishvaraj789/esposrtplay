import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../routes/route_names.dart';
import 'package:go_router/go_router.dart';
import '../provider/admin_provider.dart';
import '../widgets/dashboard_stat_card.dart';
import '../widgets/admin_action_button.dart';
import '../widgets/announcement_card.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final announcementsAsync = ref.watch(announcementsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        title: const Text('Admin Dashboard'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(dashboardStatsProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Welcome Back', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text('Admin • EsportPlay', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            const SizedBox(height: 20),

            statsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator(color: AppColors.secondary)),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text('Couldn\'t load stats: $e', style: const TextStyle(color: Colors.redAccent)),
              ),
              data: (stats) => GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  DashboardStatCard(
                    label: 'Tournaments',
                    value: stats.totalTournaments.toString(),
                    icon: Icons.emoji_events,
                    color: AppColors.secondary,
                  ),
                  DashboardStatCard(
                    label: 'Teams',
                    value: stats.totalTeams.toString(),
                    icon: Icons.groups,
                    color: const Color(0xFF3DDC84),
                  ),
                  DashboardStatCard(
                    label: 'Matches Today',
                    value: stats.matchesToday.toString(),
                    icon: Icons.sports_esports,
                    color: const Color(0xFFFFC24B),
                  ),
                  DashboardStatCard(
                    label: 'Prize Pool',
                    value: '₹${stats.totalPrizePool.toStringAsFixed(0)}',
                    icon: Icons.account_balance_wallet,
                    color: const Color(0xFFFF3D5A),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            const Text('Quick Actions', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
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
                  color: const Color(0xFF3DDC84),
                  onTap: () => context.push(Routes.adminTeams),
                ),
                AdminActionButton(
                  label: 'Manage Matches',
                  icon: Icons.sports_esports_outlined,
                  color: const Color(0xFFFFC24B),
                  onTap: () => context.push(Routes.adminMatches),
                ),
                AdminActionButton(
                  label: 'Announcements',
                  icon: Icons.campaign_outlined,
                  color: const Color(0xFF3DA9FC),
                  onTap: () => context.push(Routes.adminAnnouncements),
                ),
              ],
            ),
            const SizedBox(height: 28),

            const Text('Recent Announcements', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
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
