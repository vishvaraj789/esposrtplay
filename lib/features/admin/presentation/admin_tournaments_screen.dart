import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../routes/route_names.dart';
import '../provider/tournament_admin_provider.dart';
import '../widgets/tournament_tile.dart';

class AdminTournamentsScreen extends ConsumerWidget {
  const AdminTournamentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournaments = ref.watch(allTournamentsAdminProvider);
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(backgroundColor: AppColors.backgroundDark, title: const Text('Manage Tournaments')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.adminTournamentEditPath('new')),
        icon: const Icon(Icons.add), label: const Text('Create'),
      ),
      body: tournaments.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Could not load tournaments: $error', style: const TextStyle(color: Colors.redAccent))),
        data: (items) => items.isEmpty
            ? const _AdminEmpty(icon: Icons.emoji_events_outlined, message: 'No tournaments yet')
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (_, index) => TournamentTile(
                  tournament: items[index],
                  onTap: () => context.push(Routes.adminTournamentEditPath(items[index].id)),
                  onEdit: () => context.push(Routes.adminTournamentEditPath(items[index].id)),
                  onDelete: () => _delete(context, ref, items[index].id, items[index].name),
                ),
              ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, String id, String name) async {
    final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('Delete tournament?'), content: Text('$name will be permanently removed.'),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete'))],
    ));
    if (confirmed != true) return;
    final ok = await ref.read(tournamentAdminActionsControllerProvider.notifier).delete(id);
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Tournament deleted' : 'Could not delete tournament')));
  }
}

class _AdminEmpty extends StatelessWidget {
  final IconData icon;
  final String message;
  const _AdminEmpty({required this.icon, required this.message});
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: Colors.white38, size: 44), const SizedBox(height: 10), Text(message, style: const TextStyle(color: Colors.white60))]));
}
