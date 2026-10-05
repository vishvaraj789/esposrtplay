import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/team_admin_model.dart';
import '../repository/team_admin_repository.dart';

final teamAdminRepositoryProvider = Provider<TeamAdminRepository>((ref) => TeamAdminRepository());

final allTeamsAdminProvider = StreamProvider<List<AdminTeam>>((ref) {
  return ref.watch(teamAdminRepositoryProvider).watchAllTeams();
});

final teamDetailProvider = StreamProvider.family<AdminTeam?, String>((ref, teamId) {
  return ref.watch(teamAdminRepositoryProvider).watchTeam(teamId);
});

final teamMembersAdminProvider = StreamProvider.family<List<AdminTeamMember>, String>((ref, teamId) {
  return ref.watch(teamAdminRepositoryProvider).watchMembers(teamId);
});

final teamTournamentCountProvider = FutureProvider.autoDispose.family<int, String>((ref, teamId) {
  return ref.watch(teamAdminRepositoryProvider).fetchTournamentCount(teamId);
});

// --- Search / filter (local UI state) ---

class TeamSearchState extends Notifier<String> {
  @override
  String build() => '';
  void setQuery(String query) => state = query;
}

final teamSearchProvider = NotifierProvider<TeamSearchState, String>(TeamSearchState.new);

enum TeamFilter { all, active, suspended, verified, unverified }

class TeamFilterState extends Notifier<TeamFilter> {
  @override
  TeamFilter build() => TeamFilter.all;
  void setFilter(TeamFilter filter) => state = filter;
}

final teamFilterProvider = NotifierProvider<TeamFilterState, TeamFilter>(TeamFilterState.new);

final filteredTeamsProvider = Provider<AsyncValue<List<AdminTeam>>>((ref) {
  final teamsAsync = ref.watch(allTeamsAdminProvider);
  final query = ref.watch(teamSearchProvider).toLowerCase().trim();
  final filter = ref.watch(teamFilterProvider);

  return teamsAsync.whenData((teams) {
    return teams.where((t) {
      final matchesQuery =
          query.isEmpty || t.name.toLowerCase().contains(query) || t.tag.toLowerCase().contains(query);

      final matchesFilter = switch (filter) {
        TeamFilter.all => true,
        TeamFilter.active => !t.isSuspended,
        TeamFilter.suspended => t.isSuspended,
        TeamFilter.verified => t.verified,
        TeamFilter.unverified => !t.verified,
      };

      return matchesQuery && matchesFilter;
    }).toList();
  });
});

// --- Actions ---

class TeamAdminActionsController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  TeamAdminRepository get _repo => ref.read(teamAdminRepositoryProvider);

  Future<bool> verify(String teamId) => _run(() => _repo.setVerified(teamId, true));
  Future<bool> unverify(String teamId) => _run(() => _repo.setVerified(teamId, false));
  Future<bool> suspend(String teamId) => _run(() => _repo.setStatus(teamId, TeamStatus.suspended));
  Future<bool> activate(String teamId) => _run(() => _repo.setStatus(teamId, TeamStatus.active));
  Future<bool> removeMember(String teamId, String uid) => _run(() => _repo.removeMember(teamId: teamId, uid: uid));

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

final teamAdminActionsControllerProvider =
NotifierProvider<TeamAdminActionsController, AsyncValue<void>>(TeamAdminActionsController.new);