import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../routes/route_names.dart';
import '../../tournaments/model/tournament_model.dart';
import '../provider/tournament_admin_provider.dart';
import '../widgets/tournament_tile.dart';

enum _Filter { all, published, draft }

class AdminTournamentsScreen extends ConsumerStatefulWidget {
  const AdminTournamentsScreen({super.key});

  @override
  ConsumerState<AdminTournamentsScreen> createState() => _AdminTournamentsScreenState();
}

class _AdminTournamentsScreenState extends ConsumerState<AdminTournamentsScreen> {
  _Filter _filter = _Filter.all;

  List<Tournament> _apply(List<Tournament> items) {
    switch (_filter) {
      case _Filter.all:
        return items;
      case _Filter.published:
        return items.where((t) => t.isPublished).toList();
      case _Filter.draft:
        return items.where((t) => !t.isPublished).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tournaments = ref.watch(allTournamentsAdminProvider);
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(backgroundColor: AppColors.backgroundDark, title: const Text('Manage Tournaments')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.adminTournamentEditPath('new')),
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                for (final f in _Filter.values) ...[
                  ChoiceChip(
                    label: Text(f == _Filter.all ? 'All' : f == _Filter.published ? 'Published' : 'Drafts'),
                    selected: _filter == f,
                    onSelected: (_) => setState(() => _filter = f),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          Expanded(
            child: tournaments.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text('Could not load tournaments: $error', style: const TextStyle(color: Colors.redAccent)),
              ),
              data: (all) {
                final items = _apply(all);
                if (items.isEmpty) {
                  return const _AdminEmpty(icon: Icons.emoji_events_outlined, message: 'No tournaments here yet');
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    final t = items[index];
                    return TournamentTile(
                      tournament: t,
                      onTap: () => context.push(Routes.adminTournamentEditPath(t.id)),
                      onEdit: () => context.push(Routes.adminTournamentEditPath(t.id)),
                      onTogglePublish: () => _togglePublish(t),
                      onDelete: () => _delete(t.id, t.name),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _togglePublish(Tournament t) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await ref.read(tournamentAdminActionsControllerProvider.notifier).setPublished(t.id, !t.isPublished);
    messenger.showSnackBar(SnackBar(
      content: Text(ok
          ? (t.isPublished ? '${t.name} moved to drafts' : '${t.name} is now published')
          : 'Could not update tournament'),
    ));
  }

  Future<void> _delete(String id, String name) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete tournament?'),
        content: Text('$name, its team registrations and its banner will be permanently removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await ref.read(tournamentAdminActionsControllerProvider.notifier).delete(id);
    messenger.showSnackBar(SnackBar(content: Text(ok ? 'Tournament deleted' : 'Could not delete tournament')));
  }
}

class _AdminEmpty extends StatelessWidget {
  final IconData icon;
  final String message;
  const _AdminEmpty({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white38, size: 44),
        const SizedBox(height: 10),
        Text(message, style: const TextStyle(color: Colors.white60)),
      ],
    ),
  );
}