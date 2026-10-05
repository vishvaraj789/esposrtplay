import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/player_admin_model.dart';
import '../repository/player_admin_repository.dart';

final playerAdminRepositoryProvider = Provider<PlayerAdminRepository>((ref) => PlayerAdminRepository());

final allPlayersAdminProvider = StreamProvider<List<AdminPlayer>>((ref) {
  return ref.watch(playerAdminRepositoryProvider).watchAllPlayers();
});

final playerDetailProvider = StreamProvider.family<AdminPlayer?, String>((ref, uid) {
  return ref.watch(playerAdminRepositoryProvider).watchPlayer(uid);
});

final playerParticipationProvider = FutureProvider.autoDispose.family<PlayerParticipation, String>((ref, uid) {
  return ref.watch(playerAdminRepositoryProvider).fetchParticipation(uid);
});

// --- Search / filter (local UI state) ---

class PlayerSearchState extends Notifier<String> {
  @override
  String build() => '';
  void setQuery(String query) => state = query;
}

final playerSearchProvider = NotifierProvider<PlayerSearchState, String>(PlayerSearchState.new);

enum PlayerFilter { all, active, suspended, verified, unverified }

class PlayerFilterState extends Notifier<PlayerFilter> {
  @override
  PlayerFilter build() => PlayerFilter.all;
  void setFilter(PlayerFilter filter) => state = filter;
}

final playerFilterProvider = NotifierProvider<PlayerFilterState, PlayerFilter>(PlayerFilterState.new);

final filteredPlayersProvider = Provider<AsyncValue<List<AdminPlayer>>>((ref) {
  final playersAsync = ref.watch(allPlayersAdminProvider);
  final query = ref.watch(playerSearchProvider).toLowerCase().trim();
  final filter = ref.watch(playerFilterProvider);

  return playersAsync.whenData((players) {
    return players.where((p) {
      final matchesQuery = query.isEmpty ||
          p.nickname.toLowerCase().contains(query) ||
          p.fullName.toLowerCase().contains(query) ||
          p.email.toLowerCase().contains(query) ||
          p.freeFireUid.toLowerCase().contains(query);

      final matchesFilter = switch (filter) {
        PlayerFilter.all => true,
        PlayerFilter.active => p.status == PlayerStatus.active,
        PlayerFilter.suspended => p.status == PlayerStatus.suspended,
        PlayerFilter.verified => p.verified,
        PlayerFilter.unverified => !p.verified,
      };

      return matchesQuery && matchesFilter;
    }).toList();
  });
});

// --- Actions ---

class PlayerAdminActionsController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  PlayerAdminRepository get _repo => ref.read(playerAdminRepositoryProvider);

  Future<bool> verify(String uid) => _run(() => _repo.setVerified(uid, true));
  Future<bool> unverify(String uid) => _run(() => _repo.setVerified(uid, false));
  Future<bool> suspend(String uid) => _run(() => _repo.setStatus(uid, PlayerStatus.suspended));
  Future<bool> activate(String uid) => _run(() => _repo.setStatus(uid, PlayerStatus.active));

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
}

final playerAdminActionsControllerProvider =
NotifierProvider<PlayerAdminActionsController, AsyncValue<void>>(PlayerAdminActionsController.new);