import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../tournaments/model/tournament_model.dart';
import '../../tournaments/provider/tournament_provider.dart';

export '../../tournaments/model/tournament_model.dart' show LeaderboardEntry, Tournament, TournamentStatus;
export '../../tournaments/provider/tournament_provider.dart' show leaderboardProvider;

/// Which tournament's leaderboard is currently selected on the screen.
/// Null means "not chosen yet" — the screen defaults it to the first
/// eligible tournament once the list loads.
class SelectedLeaderboardTournament extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

final selectedLeaderboardTournamentProvider =
NotifierProvider<SelectedLeaderboardTournament, String?>(
  SelectedLeaderboardTournament.new,
);

/// Tournaments eligible to show a leaderboard for (live or completed —
/// upcoming ones have no matches yet).
final leaderboardEligibleTournamentsProvider = Provider<AsyncValue<List<Tournament>>>((ref) {
  final live = ref.watch(tournamentsProvider(TournamentStatus.live));
  final completed = ref.watch(tournamentsProvider(TournamentStatus.completed));

  if (live.isLoading || completed.isLoading) return const AsyncLoading();
  if (live.hasError) return AsyncError(live.error!, live.stackTrace!);
  if (completed.hasError) return AsyncError(completed.error!, completed.stackTrace!);

  return AsyncData([...?live.value, ...?completed.value]);
});