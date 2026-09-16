import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/match_model.dart';
import '../repository/match_repository.dart';

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return MatchRepository();
});

final upcomingMatchesProvider = StreamProvider<List<MatchModel>>((ref) {
  return ref.watch(matchRepositoryProvider).watchUpcomingMatches();
});

final liveMatchesProvider = StreamProvider<List<MatchModel>>((ref) {
  return ref.watch(matchRepositoryProvider).watchLiveMatches();
});

final tournamentMatchesProvider = StreamProvider.family<List<MatchModel>, String>((ref, tournamentId) {
  return ref.watch(matchRepositoryProvider).watchMatchesForTournament(tournamentId);
});

final matchDetailProvider = StreamProvider.family<MatchModel?, String>((ref, matchId) {
  return ref.watch(matchRepositoryProvider).watchMatch(matchId);
});

// --- Create-match (admin) ---

class CreateMatchState {
  final bool isSubmitting;
  final String? error;
  final String? createdId;

  const CreateMatchState({this.isSubmitting = false, this.error, this.createdId});
}

class CreateMatchController extends Notifier<CreateMatchState> {
  @override
  CreateMatchState build() => const CreateMatchState();

  Future<void> submit({
    required String tournamentId,
    required int round,
    required String teamAId,
    required String teamAName,
    required String teamBId,
    required String teamBName,
    required String map,
    required DateTime scheduledAt,
  }) async {
    state = const CreateMatchState(isSubmitting: true);
    try {
      final id = await ref.read(matchRepositoryProvider).createMatch(
        tournamentId: tournamentId,
        round: round,
        teamAId: teamAId,
        teamAName: teamAName,
        teamBId: teamBId,
        teamBName: teamBName,
        map: map,
        scheduledAt: scheduledAt,
      );
      state = CreateMatchState(createdId: id);
    } catch (e) {
      state = CreateMatchState(error: e.toString());
    }
  }
}

final createMatchControllerProvider =
NotifierProvider<CreateMatchController, CreateMatchState>(CreateMatchController.new);

// --- Match actions (start / end / declare winner / cancel) ---

class MatchActionsController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> start({required String matchId, required String roomId, required String roomPassword}) async {
    state = const AsyncLoading();
    try {
      await ref.read(matchRepositoryProvider).startMatch(matchId: matchId, roomId: roomId, roomPassword: roomPassword);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> end(String matchId) async {
    state = const AsyncLoading();
    try {
      await ref.read(matchRepositoryProvider).endMatch(matchId);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> declareWinner({required String matchId, required String winnerId, required String winnerName}) async {
    state = const AsyncLoading();
    try {
      await ref.read(matchRepositoryProvider).declareWinner(matchId: matchId, winnerId: winnerId, winnerName: winnerName);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> cancel(String matchId) async {
    state = const AsyncLoading();
    try {
      await ref.read(matchRepositoryProvider).cancelMatch(matchId);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final matchActionsControllerProvider =
NotifierProvider<MatchActionsController, AsyncValue<void>>(MatchActionsController.new);