import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../provider/team_admin_provider.dart';
import '../repository/team_admin_repository.dart';
import '../widgets/team_request_card.dart';

class AdminTeamsScreen extends ConsumerWidget {
  const AdminTeamsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teams = ref.watch(allTeamsAdminProvider);
    return Scaffold(backgroundColor: AppColors.backgroundDark, appBar: AppBar(backgroundColor: AppColors.backgroundDark, title: const Text('Team Approvals')), body: teams.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Could not load teams: $error', style: const TextStyle(color: Colors.redAccent))),
      data: (items) {
        final pending = items.where((team) => team.status == TeamApprovalStatus.pending).toList();
        return ListView(padding: const EdgeInsets.all(16), children: [
          Text('${pending.length} pending approval${pending.length == 1 ? '' : 's'}', style: const TextStyle(color: Colors.white70)), const SizedBox(height: 12),
          if (pending.isEmpty) const _NoPending(),
          ...pending.map((team) => TeamRequestCard(request: team, onApprove: () => _act(context, ref, team.teamId, true), onReject: () => _act(context, ref, team.teamId, false))),
          if (items.length > pending.length) ...[const SizedBox(height: 18), const Text('Reviewed teams', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)), const SizedBox(height: 8), ...items.where((team) => team.status != TeamApprovalStatus.pending).map(_ReviewTile.new)],
        ]);
      },
    ));
  }
  Future<void> _act(BuildContext context, WidgetRef ref, String id, bool approve) async {
    final ok = approve ? await ref.read(teamAdminActionsControllerProvider.notifier).approve(id) : await ref.read(teamAdminActionsControllerProvider.notifier).reject(id);
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? (approve ? 'Team approved' : 'Team rejected') : 'Could not update team')));
  }
}
class _NoPending extends StatelessWidget { const _NoPending(); @override Widget build(BuildContext context) => const Padding(padding: EdgeInsets.symmetric(vertical: 28), child: Center(child: Text('No teams are awaiting approval', style: TextStyle(color: Colors.white54)))); }
class _ReviewTile extends StatelessWidget { final TeamApprovalRequest team; const _ReviewTile(this.team); @override Widget build(BuildContext context) { final approved = team.status == TeamApprovalStatus.approved; return Container(margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(color: const Color(0xFF171821), borderRadius: BorderRadius.circular(12)), child: ListTile(leading: Icon(approved ? Icons.check_circle : Icons.cancel, color: approved ? Colors.greenAccent : Colors.redAccent), title: Text(team.name, style: const TextStyle(color: Colors.white)), subtitle: Text(team.tag, style: const TextStyle(color: Colors.white54)), trailing: Text(approved ? 'Approved' : 'Rejected', style: TextStyle(color: approved ? Colors.greenAccent : Colors.redAccent, fontSize: 12)))); }}
