import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../models/team_admin_model.dart';
import '../provider/team_admin_provider.dart';

class AdminTeamDetailsScreen extends ConsumerWidget {
  final String teamId;

  const AdminTeamDetailsScreen({super.key, required this.teamId});

  Future<void> _confirmAndRun(
      BuildContext context, {
        required String title,
        required String message,
        required Future<bool> Function() action,
        bool isDanger = false,
      }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: isDanger ? AppColors.danger : AppColors.primary),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final messenger = ScaffoldMessenger.of(context);
    final ok = await action();
    if (!ok) messenger.showSnackBar(const SnackBar(content: Text('Action failed')));
  }

  String _date(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamAsync = ref.watch(teamDetailProvider(teamId));
    final membersAsync = ref.watch(teamMembersAdminProvider(teamId));
    final countAsync = ref.watch(teamTournamentCountProvider(teamId));
    final actions = ref.read(teamAdminActionsControllerProvider.notifier);
    final busy = ref.watch(teamAdminActionsControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(backgroundColor: AppColors.backgroundDark, elevation: 0, title: const Text('Team Details')),
      body: teamAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.secondary)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
        data: (team) {
          if (team == null) {
            return const Center(child: Text('Team not found', style: TextStyle(color: Colors.white)));
          }

          final members = membersAsync.value ?? const <AdminTeamMember>[];
          final captain = members.where((m) => m.isCaptain).firstOrNull;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ---- Header: logo, name, status ----
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.hairline,
                      backgroundImage:
                      team.logoUrl != null && team.logoUrl!.isNotEmpty ? NetworkImage(team.logoUrl!) : null,
                      child: team.logoUrl == null || team.logoUrl!.isEmpty
                          ? const Icon(Icons.shield, color: Colors.white54, size: 36)
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(team.name,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                        if (team.verified) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.verified, color: AppColors.secondary, size: 18),
                        ],
                      ],
                    ),
                    Text(
                      team.isSuspended ? 'SUSPENDED' : 'Active',
                      style: TextStyle(
                        color: team.isSuspended ? AppColors.danger : AppColors.green,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ---- Details ----
              _card([
                _row('Team name', team.name),
                _row('Tag', team.tag.isEmpty ? '—' : team.tag),
                _row('Captain', captain?.name ?? (team.captainUid.isEmpty ? '—' : team.captainUid)),
                _row('Members', '${team.memberUids.length}/${team.maxMembers}'),
                _row('Created', team.createdAt.millisecondsSinceEpoch == 0 ? '—' : _date(team.createdAt)),
                _row('Tournaments', countAsync.when(
                  data: (n) => '$n',
                  loading: () => '…',
                  error: (_, __) => '—',
                )),
                _row('Verified', team.verified ? 'Yes' : 'No'),
                _row('Status', team.isSuspended ? 'Suspended' : 'Active'),
              ]),
              const SizedBox(height: 24),

              // ---- Members ----
              const Text('Members', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              membersAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator(color: AppColors.secondary)),
                ),
                error: (e, _) => Text('Could not load members: $e', style: const TextStyle(color: Colors.redAccent)),
                data: (list) {
                  if (list.isEmpty) {
                    return Text('No members', style: TextStyle(color: AppColors.textSecondary));
                  }
                  return Column(
                    children: list
                        .map((m) => _MemberTile(
                      member: m,
                      onRemove: m.isCaptain || busy
                          ? null
                          : () => _confirmAndRun(
                        context,
                        isDanger: true,
                        title: 'Remove member',
                        message: 'Remove ${m.name} from ${team.name}? They will have to rejoin with the invite code.',
                        action: () => actions.removeMember(teamId, m.uid),
                      ),
                    ))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 24),

              // ---- Admin actions ----
              const Text('Admin Actions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              AppButton(
                text: team.verified ? 'Remove Verification' : 'Verify Team',
                icon: Icons.verified_outlined,
                variant: AppButtonVariant.outline,
                isLoading: busy,
                onPressed: () => _confirmAndRun(
                  context,
                  title: team.verified ? 'Remove Verification' : 'Verify Team',
                  message: team.verified
                      ? 'Remove the verified badge from ${team.name}?'
                      : 'Mark ${team.name} as verified?',
                  action: () => team.verified ? actions.unverify(teamId) : actions.verify(teamId),
                ),
              ),
              const SizedBox(height: 10),
              AppButton(
                text: team.isSuspended ? 'Activate Team' : 'Suspend Team',
                icon: team.isSuspended ? Icons.check_circle_outline : Icons.block,
                variant: team.isSuspended ? AppButtonVariant.primary : AppButtonVariant.danger,
                isLoading: busy,
                onPressed: () => _confirmAndRun(
                  context,
                  isDanger: !team.isSuspended,
                  title: team.isSuspended ? 'Activate Team' : 'Suspend Team',
                  message: team.isSuspended
                      ? 'Restore ${team.name}? It can register for tournaments again.'
                      : '${team.name} will be blocked from registering for tournaments. Continue?',
                  action: () => team.isSuspended ? actions.activate(teamId) : actions.suspend(teamId),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _card(List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.hairline),
    ),
    padding: const EdgeInsets.all(14),
    child: Column(children: children),
  );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(child: Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 13))),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );
}

class _MemberTile extends StatelessWidget {
  final AdminTeamMember member;
  final VoidCallback? onRemove;

  const _MemberTile({required this.member, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.hairline),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.hairline,
          child: Text(
            member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(member.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
            if (member.isCaptain) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('CAPTAIN',
                    style: TextStyle(color: AppColors.gold, fontSize: 9.5, fontWeight: FontWeight.w800)),
              ),
            ],
          ],
        ),
        subtitle: Text(member.role, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        trailing: member.isCaptain
            ? null
            : IconButton(
          tooltip: 'Remove member',
          icon: const Icon(Icons.person_remove_outlined, color: Colors.redAccent, size: 20),
          onPressed: onRemove,
        ),
      ),
    );
  }
}