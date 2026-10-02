import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/empty_widget.dart';
import '../../../routes/route_names.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/team_provider.dart';
import '../repository/team_repository.dart';
import '../widgets/captain_badge.dart';
import '../widgets/player_tile.dart';

const _kBg = Color(0xFF0B0C12);
const _kCard = Color(0xFF171821);
const _kHairline = Color(0xFF2A2C38);
const _kTextSecondary = Color(0xFF9CA0AF);
const _kPurple = Color(0xFF8B5CF6);
const _kGold = Color(0xFFFFC24B);
const _kPink = Color(0xFFFF3D5A);
const _kBrandGradient = LinearGradient(
  colors: [Color(0xFFFF6A3D), Color(0xFFFF3D5A)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

String _cleanError(Object e) => e.toString().replaceFirst('Exception: ', '');

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

/// Team page: identity, stats, squad list, and role-appropriate actions
/// (invite code + chat + leave for members; transfer/remove for the captain).
class TeamDetailsScreen extends ConsumerWidget {
  final String teamId;

  const TeamDetailsScreen({super.key, required this.teamId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamAsync = ref.watch(teamDetailProvider(teamId));

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        centerTitle: true,
        title: const Text('Team', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: teamAsync.when(
        loading: () => const AppLoader(),
        error: (e, _) => const EmptyWidget(
          icon: Icons.error_outline,
          message: 'Could not load this team.\nCheck your connection and try again.',
        ),
        data: (team) {
          if (team == null) {
            return const EmptyWidget(icon: Icons.search_off, message: 'Team not found');
          }
          return _Body(team: team);
        },
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  final TeamModel team;

  const _Body({required this.team});

  Future<void> _showMemberMenu(
      BuildContext context,
      WidgetRef ref,
      TeamMember member,
      String myUid,
      ) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: _kCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.workspace_premium, color: _kGold),
              title: const Text('Make captain', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.of(ctx).pop('captain'),
            ),
            ListTile(
              leading: const Icon(Icons.person_remove_outlined, color: _kPink),
              title: const Text('Remove from team', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.of(ctx).pop('remove'),
            ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;

    final repo = ref.read(teamRepositoryProvider);

    if (action == 'captain') {
      final ok = await AppDialog.confirm(
        context,
        title: 'Make ${member.name} captain?',
        message: 'You will lose captain controls for this team.',
        confirmText: 'Transfer',
      );
      if (ok != true || !context.mounted) return;
      try {
        await repo.transferCaptain(teamId: team.id, newCaptainUid: member.uid, oldCaptainUid: myUid);
        if (context.mounted) _snack(context, '${member.name} is now captain');
      } catch (e) {
        if (context.mounted) _snack(context, _cleanError(e));
      }
    } else if (action == 'remove') {
      final ok = await AppDialog.confirm(
        context,
        title: 'Remove ${member.name}?',
        message: 'They will be removed from the squad.',
        confirmText: 'Remove',
        isDanger: true,
      );
      if (ok != true || !context.mounted) return;
      try {
        await repo.removeMember(teamId: team.id, uid: member.uid);
        if (context.mounted) _snack(context, '${member.name} removed');
      } catch (e) {
        if (context.mounted) _snack(context, _cleanError(e));
      }
    }
  }

  Future<void> _leave(BuildContext context, WidgetRef ref, String uid) async {
    final ok = await AppDialog.confirm(
      context,
      title: 'Leave ${team.name}?',
      message: "You'll need a new invite code to rejoin.",
      confirmText: 'Leave',
      isDanger: true,
    );
    if (ok != true || !context.mounted) return;
    try {
      await ref.read(teamRepositoryProvider).leaveTeam(teamId: team.id, uid: uid);
      if (context.mounted) context.go(Routes.home);
    } catch (e) {
      if (context.mounted) _snack(context, _cleanError(e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authStateProvider).value?.uid;
    final isMember = uid != null && team.memberUids.contains(uid);
    final isCaptain = uid != null && uid == team.captainUid;
    final membersAsync = ref.watch(teamMembersProvider(team.id));

    final stats = [
      ('Matches', '${team.matches}'),
      ('Wins', '${team.wins}'),
      ('Win Rate', '${(team.winRate * 100).round()}%'),
      ('Rank', team.rank == 0 ? '—' : '#${team.rank}'),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        // Identity card
        Container(
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kPurple.withOpacity(0.45)),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(gradient: _kBrandGradient, borderRadius: BorderRadius.circular(14)),
                child: team.logoUrl != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(team.logoUrl!, fit: BoxFit.cover),
                )
                    : const Icon(Icons.shield, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(team.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                        ),
                        if (isCaptain) ...[
                          const SizedBox(width: 6),
                          const CaptainBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${team.memberUids.length} / ${team.maxMembers} members · Tag: ${team.tag}',
                        style: const TextStyle(color: _kTextSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Stats row
        Container(
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kHairline),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: List.generate(stats.length, (i) {
              final (label, value) = stats[i];
              return Expanded(
                child: Row(
                  children: [
                    if (i > 0) Container(width: 1, height: 26, color: _kHairline),
                    Expanded(
                      child: Column(
                        children: [
                          Text(value,
                              style: const TextStyle(
                                  color: _kGold, fontSize: 15, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 3),
                          Text(label, style: const TextStyle(color: _kTextSecondary, fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),

        // Invite code — members only
        if (isMember && team.inviteCode.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kHairline),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Invite Code', style: TextStyle(color: _kTextSecondary, fontSize: 11)),
                      const SizedBox(height: 3),
                      Text(team.inviteCode,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 3)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Copy code',
                  icon: const Icon(Icons.copy_rounded, color: _kTextSecondary, size: 20),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: team.inviteCode));
                    if (context.mounted) _snack(context, 'Invite code copied');
                  },
                ),
              ],
            ),
          ),
        ],

        // Squad
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Squad Members',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            Text('${team.memberUids.length}/${team.maxMembers}',
                style: const TextStyle(color: _kTextSecondary, fontSize: 12.5)),
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
            child: Text('Could not load members', style: TextStyle(color: _kTextSecondary)),
          ),
          data: (members) => Column(
            children: members
                .map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PlayerTile(
                member: m,
                showMoreMenu: isCaptain,
                onMoreTap: isCaptain ? () => _showMemberMenu(context, ref, m, uid!) : null,
              ),
            ))
                .toList(),
          ),
        ),

        // Member actions
        if (isMember) ...[
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push(
                Routes.teamChat,
                extra: {'teamId': team.id, 'teamName': team.name},
              ),
              icon: const Icon(Icons.chat_bubble_outline, color: _kPurple, size: 18),
              label: const Text('Team Chat',
                  style: TextStyle(color: _kPurple, fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                side: const BorderSide(color: _kPurple, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (isCaptain)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Captains must transfer captaincy before leaving the team.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _kTextSecondary, fontSize: 12),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _leave(context, ref, uid!),
                icon: const Icon(Icons.logout, color: _kTextSecondary, size: 18),
                label: const Text('Leave Team',
                    style: TextStyle(color: _kTextSecondary, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  side: const BorderSide(color: _kHairline),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
        ],
      ],
    );
  }
}