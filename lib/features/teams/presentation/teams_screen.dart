import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/empty_widget.dart';
import '../../../routes/route_names.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/team_provider.dart';
import '../repository/team_repository.dart';
import '../widgets/player_tile.dart';
import '../widgets/team_actions.dart';
import '../widgets/team_card.dart';

/// Teams tab. Shows the signed-in user's squad (live from Firestore), or the
/// create / join options when they aren't on a team yet.
class TeamsScreen extends ConsumerWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authStateProvider).value?.uid;

    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: SafeArea(
        child: uid == null
            ? const AppLoader()
            : ref.watch(userTeamProvider(uid)).when(
          loading: () => const AppLoader(),
          error: (e, _) => EmptyWidget(
            icon: Icons.error_outline,
            message: 'Could not load your team.\nCheck your connection and try again.',
            action: TextButton(
              onPressed: () => ref.invalidate(userTeamProvider(uid)),
              child: const Text('Retry'),
            ),
          ),
          data: (team) => team == null ? const _EmptyState() : _TeamView(team: team, uid: uid),
        ),
      ),
    );
  }
}

// ============================================================================
// HEADER
// ============================================================================
class _Header extends StatelessWidget {
  final Widget? action;

  const _Header({this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Teams',
                  style: TextStyle(color: AppColors.white, fontSize: 26, fontWeight: FontWeight.w800)),
              SizedBox(height: 2),
              Text('Squad up. Sync up. Win.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

// ============================================================================
// HAS-TEAM VIEW
// ============================================================================
class _TeamView extends ConsumerWidget {
  final TeamModel team;
  final String uid;

  const _TeamView({required this.team, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCaptain = uid == team.captainUid;
    final membersAsync = ref.watch(teamMembersProvider(team.id));

    final stats = [
      ('Matches', '${team.matches}'),
      ('Wins', '${team.wins}'),
      ('Win Rate', '${(team.winRate * 100).round()}%'),
      ('Rank', team.rank == 0 ? '—' : '#${team.rank}'),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _Header(
          action: GestureDetector(
            onTap: () => showInviteCodeSheet(context, team),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: AppColors.card, shape: BoxShape.circle),
              child: const Icon(Icons.person_add_alt_1, color: AppColors.white, size: 20),
            ),
          ),
        ),
        const SizedBox(height: 18),
        TeamCard(
          team: team,
          isViewerCaptain: isCaptain,
          onTap: () => context.push(Routes.teamDetailsPath(team.id)),
        ),
        const SizedBox(height: 16),
        _StatsRow(stats: stats),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Squad Members',
                style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            Text('${team.memberUids.length}/${team.maxMembers}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
          ],
        ),
        const SizedBox(height: 12),
        membersAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: AppLoader(size: 24),
          ),
          error: (e, _) => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('Could not load members', style: TextStyle(color: AppColors.textSecondary)),
          ),
          data: (members) => Column(
            children: [
              for (final m in members)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: PlayerTile(
                    member: m,
                    // Captains manage everyone but themselves.
                    showMoreMenu: isCaptain && m.uid != uid,
                    onMoreTap: isCaptain && m.uid != uid
                        ? () => showTeamMemberMenu(context, ref, team: team, member: m, myUid: uid)
                        : null,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (isCaptain)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Text(
              'Captains must transfer captaincy before leaving the team.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final left = await confirmAndLeaveTeam(context, ref, team: team, uid: uid);
                // The live team stream flips this tab to the empty state on its own.
                if (left) {
                  messenger
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text('You left ${team.name}')));
                }
              },
              icon: const Icon(Icons.logout, color: AppColors.textSecondary, size: 18),
              label: const Text('Leave Team',
                  style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                side: const BorderSide(color: AppColors.hairline),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
      ],
    );
  }
}

// ============================================================================
// STATS ROW — team-level performance
// ============================================================================
class _StatsRow extends StatelessWidget {
  final List<(String, String)> stats;

  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.hairline),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: List.generate(stats.length, (i) {
          final (label, value) = stats[i];
          return Expanded(
            child: Row(
              children: [
                if (i > 0) Container(width: 1, height: 26, color: AppColors.hairline),
                Expanded(
                  child: Column(
                    children: [
                      Text(value,
                          style: const TextStyle(
                              color: AppColors.gold, fontSize: 15, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text(label,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ============================================================================
// EMPTY STATE — no team yet
// ============================================================================
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Header(),
          const Spacer(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.hairline),
                  ),
                  child: const Icon(Icons.groups_outlined, color: AppColors.textSecondary, size: 36),
                ),
                const SizedBox(height: 16),
                const Text('You are not on a team yet',
                    style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Text(
                  'Create your own squad or join one with an invite code.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton.icon(
                onPressed: () => context.push(Routes.teamCreate),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Create a Team',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final joinedId = await showJoinTeamSheet(context);
                // The live team stream flips this tab to the team view on its own.
                if (joinedId != null) {
                  messenger
                    ..hideCurrentSnackBar()
                    ..showSnackBar(const SnackBar(content: Text('Welcome to the squad!')));
                }
              },
              icon: const Icon(Icons.login, color: AppColors.purple),
              label: const Text('Join a Team',
                  style: TextStyle(color: AppColors.purple, fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.purple, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}