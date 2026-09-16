import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../tournaments/model/tournament_model.dart';
import '../repository/tournament_admin_repository.dart';

final tournamentAdminRepositoryProvider = Provider<TournamentAdminRepository>((ref) => TournamentAdminRepository());

final allTournamentsAdminProvider = StreamProvider<List<Tournament>>((ref) {
  return ref.watch(tournamentAdminRepositoryProvider).watchAllTournaments();
});

class TournamentAdminActionsController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> update(String id, Map<String, dynamic> updates) async {
    state = const AsyncLoading();
    try {
      await ref.read(tournamentAdminRepositoryProvider).updateTournament(id, updates);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> delete(String id) async {
    state = const AsyncLoading();
    try {
      await ref.read(tournamentAdminRepositoryProvider).deleteTournament(id);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> setStatus(String id, TournamentStatus status) async {
    state = const AsyncLoading();
    try {
      await ref.read(tournamentAdminRepositoryProvider).setStatus(id, status);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final tournamentAdminActionsControllerProvider =
NotifierProvider<TournamentAdminActionsController, AsyncValue<void>>(TournamentAdminActionsController.new);