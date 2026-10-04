import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/tournament_model.dart';
import '../repository/tournament_repository.dart';

final tournamentRepositoryProvider = Provider<TournamentRepository>((ref) {
  return TournamentRepository();
});

final tournamentsProvider =
StreamProvider.family<List<Tournament>, TournamentStatus?>((ref, status) {
  return ref.watch(tournamentRepositoryProvider).watchTournaments(status: status);
});

/// Live tournaments first, then upcoming — feeds Home's "Live & Upcoming" row.
/// Built on [tournamentsProvider] (same server-side status filter the
/// Tournaments tab and leaderboard use) rather than a second Firestore query.
final liveAndUpcomingTournamentsProvider = Provider<AsyncValue<List<Tournament>>>((ref) {
  final live = ref.watch(tournamentsProvider(TournamentStatus.live));
  final upcoming = ref.watch(tournamentsProvider(TournamentStatus.upcoming));

  if (live.isLoading || upcoming.isLoading) return const AsyncLoading();
  if (live.hasError) return AsyncError(live.error!, live.stackTrace!);
  if (upcoming.hasError) return AsyncError(upcoming.error!, upcoming.stackTrace!);

  return AsyncData([...?live.value, ...?upcoming.value].take(10).toList());
});

final tournamentDetailProvider = StreamProvider.family<Tournament?, String>((ref, id) {
  return ref.watch(tournamentRepositoryProvider).watchTournament(id);
});

final registrationsProvider = StreamProvider.family<List<TeamRegistration>, String>((ref, tournamentId) {
  return ref.watch(tournamentRepositoryProvider).watchRegistrations(tournamentId);
});

final userTeamsProvider = StreamProvider.family<List<Team>, String>((ref, uid) {
  return ref.watch(tournamentRepositoryProvider).watchTeamsForUser(uid);
});


final leaderboardProvider = StreamProvider.family<List<LeaderboardEntry>, String>((ref, tournamentId) {
  return ref.watch(tournamentRepositoryProvider).watchLeaderboard(tournamentId);
});

// --- Create-tournament form state ---

class CreateTournamentState {
  final bool isSubmitting;
  final String? error;
  final String? createdId;

  const CreateTournamentState({this.isSubmitting = false, this.error, this.createdId});
}

class CreateTournamentController extends Notifier<CreateTournamentState> {
  @override
  CreateTournamentState build() => const CreateTournamentState();

  Future<void> submit(Tournament draft) async {
    state = const CreateTournamentState(isSubmitting: true);
    try {
      final id = await ref.read(tournamentRepositoryProvider).createTournament(draft);
      state = CreateTournamentState(createdId: id);
    } catch (e) {
      state = CreateTournamentState(error: e.toString());
    }
  }
}

final createTournamentControllerProvider =
NotifierProvider<CreateTournamentController, CreateTournamentState>(
  CreateTournamentController.new,
);

// --- Register-team action ---

class RegisterTeamController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> register({
    required String tournamentId,
    required String teamId,
    required String teamName,
    String? logoUrl,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(tournamentRepositoryProvider).registerTeam(
        tournamentId: tournamentId,
        teamId: teamId,
        teamName: teamName,
        logoUrl: logoUrl,
      );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final registerTeamControllerProvider =
NotifierProvider<RegisterTeamController, AsyncValue<void>>(
  RegisterTeamController.new,
);