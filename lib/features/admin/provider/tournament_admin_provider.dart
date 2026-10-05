import 'dart:io';

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

  TournamentAdminRepository get _repo => ref.read(tournamentAdminRepositoryProvider);

  /// Runs [action], mirroring progress/errors into [state]. Returns true on success.
  Future<bool> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    try {
      await action();
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> create(Map<String, dynamic> data, {File? banner}) =>
      _run(() => _repo.createTournament(data, banner: banner));

  Future<bool> update(
      String id,
      Map<String, dynamic> updates, {
        File? banner,
        bool removeBanner = false,
      }) =>
      _run(() => _repo.updateTournament(id, updates, banner: banner, removeBanner: removeBanner));

  Future<bool> delete(String id) => _run(() => _repo.deleteTournament(id));

  Future<bool> setStatus(String id, TournamentStatus status) => _run(() => _repo.setStatus(id, status));

  Future<bool> setPublished(String id, bool published) => _run(() => _repo.setPublished(id, published));
}

final tournamentAdminActionsControllerProvider =
NotifierProvider<TournamentAdminActionsController, AsyncValue<void>>(TournamentAdminActionsController.new);