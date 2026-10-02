import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../matches/models/match_model.dart';
import '../../matches/provider/match_provider.dart';
import '../../matches/widgets/match_card.dart';
import '../../matches/widgets/room_info_card.dart';
import '../../matches/widgets/winner_dialog.dart';

class AdminMatchManageScreen extends ConsumerStatefulWidget {
  final String matchId;
  const AdminMatchManageScreen({super.key, required this.matchId});
  @override
  ConsumerState<AdminMatchManageScreen> createState() => _AdminMatchManageScreenState();
}

class _AdminMatchManageScreenState extends ConsumerState<AdminMatchManageScreen> {
  final _roomId = TextEditingController();
  final _password = TextEditingController();
  @override
  void dispose() { _roomId.dispose(); _password.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final match = ref.watch(matchDetailProvider(widget.matchId)); final busy = ref.watch(matchActionsControllerProvider).isLoading;
    return Scaffold(backgroundColor: AppColors.backgroundDark, appBar: AppBar(backgroundColor: AppColors.backgroundDark, title: const Text('Manage Match')), body: match.when(
      loading: () => const Center(child: CircularProgressIndicator()), error: (error, _) => Center(child: Text('Could not load match: $error', style: const TextStyle(color: Colors.redAccent))),
      data: (item) { if (item == null) return const Center(child: Text('Match not found', style: TextStyle(color: Colors.white70))); if (_roomId.text.isEmpty && item.roomId != null) _roomId.text = item.roomId!; if (_password.text.isEmpty && item.roomPassword != null) _password.text = item.roomPassword!; return ListView(padding: const EdgeInsets.all(16), children: [
        MatchCard(match: item), const SizedBox(height: 16), RoomInfoCard(roomId: item.roomId, roomPassword: item.roomPassword), const SizedBox(height: 20),
        if (item.status == MatchStatus.upcoming) ...[_field(_roomId, 'Room ID'), const SizedBox(height: 12), _field(_password, 'Room password'), const SizedBox(height: 16), AppButton(text: 'Start match', icon: Icons.play_arrow, isLoading: busy, onPressed: busy ? null : () => _start(item))],
        if (item.status == MatchStatus.live) ...[AppButton(text: 'Declare winner', icon: Icons.emoji_events, isLoading: busy, onPressed: busy ? null : () => _winner(item)), const SizedBox(height: 12), AppButton(text: 'End without winner', variant: AppButtonVariant.outline, isLoading: busy, onPressed: busy ? null : () => _end(item))],
        if (item.status == MatchStatus.upcoming || item.status == MatchStatus.live) ...[const SizedBox(height: 12), AppButton(text: 'Cancel match', variant: AppButtonVariant.danger, isLoading: busy, onPressed: busy ? null : () => _cancel(item))],
      ]); },
    ));
  }
  Widget _field(TextEditingController controller, String label) => TextField(controller: controller, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.white70), filled: true, fillColor: AppColors.surfaceDark, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)));
  Future<void> _start(MatchModel item) async { if (_roomId.text.trim().isEmpty || _password.text.trim().isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter room ID and password'))); return; } await _run(ref.read(matchActionsControllerProvider.notifier).start(matchId: item.id, roomId: _roomId.text.trim(), roomPassword: _password.text.trim())); }
  Future<void> _winner(MatchModel item) async { final winner = await WinnerDialog.show(context, item); if (winner != null) await _run(ref.read(matchActionsControllerProvider.notifier).declareWinner(matchId: item.id, winnerId: winner.$1, winnerName: winner.$2)); }
  Future<void> _end(MatchModel item) => _run(ref.read(matchActionsControllerProvider.notifier).end(item.id));
  Future<void> _cancel(MatchModel item) => _run(ref.read(matchActionsControllerProvider.notifier).cancel(item.id));
  Future<void> _run(Future<bool> action) async { final ok = await action; if (mounted && !ok) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Action failed. Please try again.'))); }
}
