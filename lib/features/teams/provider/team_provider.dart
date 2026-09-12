import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/team_repository.dart';

final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  return TeamRepository();
});

final userTeamProvider = StreamProvider.family<TeamModel?, String>((ref, uid) {
  return ref.watch(teamRepositoryProvider).watchUserTeam(uid);
});

final teamDetailProvider = StreamProvider.family<TeamModel?, String>((ref, teamId) {
  return ref.watch(teamRepositoryProvider).watchTeam(teamId);
});

final teamMembersProvider = StreamProvider.family<List<TeamMember>, String>((ref, teamId) {
  return ref.watch(teamRepositoryProvider).watchMembers(teamId);
});

// --- Create-team action ---

class CreateTeamController extends Notifier<AsyncValue<String?>> {
  @override
  AsyncValue<String?> build() => const AsyncData(null);

  Future<String?> create({
    required String name,
    required String tag,
    required String captainUid,
    required String captainName,
    required String captainRole,
  }) async {
    state = const AsyncLoading();
    try {
      final id = await ref.read(teamRepositoryProvider).createTeam(
        name: name,
        tag: tag,
        captainUid: captainUid,
        captainName: captainName,
        captainRole: captainRole,
      );
      state = AsyncData(id);
      return id;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

final createTeamControllerProvider =
NotifierProvider<CreateTeamController, AsyncValue<String?>>(CreateTeamController.new);

// --- Join-team action ---

class JoinTeamController extends Notifier<AsyncValue<String?>> {
  @override
  AsyncValue<String?> build() => const AsyncData(null);

  Future<String?> join({
    required String inviteCode,
    required String uid,
    required String name,
    required String role,
  }) async {
    state = const AsyncLoading();
    try {
      final id = await ref.read(teamRepositoryProvider).joinByInviteCode(
        inviteCode: inviteCode,
        uid: uid,
        name: name,
        role: role,
      );
      state = AsyncData(id);
      return id;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }
}

final joinTeamControllerProvider =
NotifierProvider<JoinTeamController, AsyncValue<String?>>(JoinTeamController.new);