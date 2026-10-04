import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../admin/provider/admin_provider.dart';
import '../../matches/models/match_model.dart';
import '../../matches/provider/match_provider.dart'; // CHANGED: was tournament_provider.dart
import '../../matches/widgets/winner_dialog.dart';
import '../widgets/bracket_widget.dart';

class BracketScreen extends ConsumerWidget {
  final String tournamentId;

  const BracketScreen({super.key, required this.tournamentId});

  Future<void> _handleMatchTap(BuildContext context, WidgetRef ref, MatchModel match) async {
    final isAdmin = ref.watch(isAdminProvider);
    if (!isAdmin || match.isCompleted) return;

    final result = await WinnerDialog.show(context, match);
    if (result == null) return;

    final (winnerId, winnerName) = result;
    await ref.read(matchActionsControllerProvider.notifier).declareWinner(
      matchId: match.id,
      winnerId: winnerId,
      winnerName: winnerName,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(tournamentMatchesProvider(tournamentId));

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        title: const Text('Bracket'),
      ),
      body: matchesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.secondary)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
        data: (matches) => Padding(
          padding: const EdgeInsets.all(16),
          child: BracketWidget(
            matches: matches,
            onMatchTap: (match) => _handleMatchTap(context, ref, match),
          ),
        ),
      ),
    );
  }
}