import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../models/player_admin_model.dart';
import '../provider/player_admin_provider.dart';

class AdminPlayerDetailsScreen extends ConsumerWidget {
  final String uid;

  const AdminPlayerDetailsScreen({super.key, required this.uid});

  Future<void> _confirmAndRun(
      BuildContext context,
      WidgetRef ref, {
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

    final ok = await action();
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Action failed')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerAsync = ref.watch(playerDetailProvider(uid));
    final actionsController = ref.read(playerAdminActionsControllerProvider.notifier);
    final actionsState = ref.watch(playerAdminActionsControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(backgroundColor: AppColors.backgroundDark, elevation: 0, title: const Text('Player Details')),
      body: playerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.secondary)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
        data: (player) {
          if (player == null) {
            return const Center(child: Text('Player not found', style: TextStyle(color: Colors.white)));
          }

          final participationAsync = ref.watch(playerParticipationProvider(uid));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.hairline,
                      backgroundImage: player.photoUrl != null ? NetworkImage(player.photoUrl!) : null,
                      child: player.photoUrl == null
                          ? Text(player.nickname.isNotEmpty ? player.nickname[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white, fontSize: 28))
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(player.nickname, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                        if (player.verified) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.verified, color: AppColors.secondary, size: 18),
                        ],
                      ],
                    ),
                    Text(
                      player.status == PlayerStatus.suspended ? 'SUSPENDED' : 'Active',
                      style: TextStyle(
                        color: player.status == PlayerStatus.suspended ? AppColors.danger : AppColors.green,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _detailCard([
                _detailRow('Username', player.nickname),
                _detailRow('Full Name', player.fullName),
                _detailRow('Free Fire UID', player.freeFireUid),
                _detailRow('Email', player.email),
                _detailRow('Phone', player.phone ?? 'Not provided'),
                _detailRow('Rank', player.rank > 0 ? '#${player.rank}' : '—'),
                _detailRow('Joined', '${player.joinedAt.day}/${player.joinedAt.month}/${player.joinedAt.year}'),
              ]),
              const SizedBox(height: 16),
              participationAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator(color: AppColors.secondary)),
                ),
                error: (e, _) => const SizedBox.shrink(),
                data: (participation) => _detailCard([
                  _detailRow('Team', participation.teamName ?? 'No team'),
                  _detailRow('Tournaments Joined', participation.tournamentCount.toString()),
                ]),
              ),
              const SizedBox(height: 28),
              const Text('Admin Actions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              AppButton(
                text: player.verified ? 'Remove Verification' : 'Verify Player',
                icon: Icons.verified_outlined,
                variant: AppButtonVariant.outline,
                isLoading: actionsState.isLoading,
                onPressed: () => _confirmAndRun(
                  context,
                  ref,
                  title: player.verified ? 'Remove Verification' : 'Verify Player',
                  message: player.verified
                      ? 'Remove the verified badge from ${player.nickname}?'
                      : 'Mark ${player.nickname} as verified?',
                  action: () => player.verified ? actionsController.unverify(uid) : actionsController.verify(uid),
                ),
              ),
              const SizedBox(height: 10),
              AppButton(
                text: player.status == PlayerStatus.suspended ? 'Activate Player' : 'Suspend Player',
                icon: player.status == PlayerStatus.suspended ? Icons.check_circle_outline : Icons.block,
                variant: player.status == PlayerStatus.suspended ? AppButtonVariant.primary : AppButtonVariant.danger,
                isLoading: actionsState.isLoading,
                onPressed: () => _confirmAndRun(
                  context,
                  ref,
                  isDanger: player.status != PlayerStatus.suspended,
                  title: player.status == PlayerStatus.suspended ? 'Activate Player' : 'Suspend Player',
                  message: player.status == PlayerStatus.suspended
                      ? 'Restore access for ${player.nickname}?'
                      : 'This blocks ${player.nickname} from the app. Continue?',
                  action: () => player.status == PlayerStatus.suspended
                      ? actionsController.activate(uid)
                      : actionsController.suspend(uid),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _detailCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.hairline)),
      padding: const EdgeInsets.all(14),
      child: Column(children: children),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 13))),
          Expanded(
            child: Text(value, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}