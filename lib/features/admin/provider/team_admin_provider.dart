import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/team_admin_repository.dart';

final teamAdminRepositoryProvider = Provider<TeamAdminRepository>((ref) => TeamAdminRepository());

final pendingTeamsProvider = StreamProvider<List<TeamApprovalRequest>>((ref) {
  return ref.watch(teamAdminRepositoryProvider).watchPendingTeams();
});

final allTeamsAdminProvider = StreamProvider<List<TeamApprovalRequest>>((ref) {
  return ref.watch(teamAdminRepositoryProvider).watchAllTeams();
});

class TeamAdminActionsController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> approve(String teamId) async {
    state = const AsyncLoading();
    try {
      await ref.read(teamAdminRepositoryProvider).approveTeam(teamId);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> reject(String teamId) async {
    state = const AsyncLoading();
    try {
      await ref.read(teamAdminRepositoryProvider).rejectTeam(teamId);
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