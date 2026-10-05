import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/admin_claim.dart';
import '../../auth/provider/auth_provider.dart';
import '../models/admin_stats_model.dart';
import '../models/announcement_model.dart';
import '../repository/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) => AdminRepository());

/// Resolves the admin custom claim from the current user's ID token.
/// Re-evaluates whenever authStateProvider emits (sign-in, sign-out, token refresh).
final _adminClaimProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return false;
  return userHasAdminClaim(user);
});

/// True only once the admin claim is confirmed on the ID token.
/// False while loading, signed out, or on error: never fails open.
final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(_adminClaimProvider).value ?? false;
});

final dashboardStatsProvider = FutureProvider.autoDispose<AdminStats>((ref) {
  return ref.watch(adminRepositoryProvider).fetchDashboardStats();
});

final recentActivityProvider = FutureProvider.autoDispose<List<AdminActivity>>((ref) {
  return ref.watch(adminRepositoryProvider).fetchRecentActivity();
});

final announcementsProvider = StreamProvider<List<AnnouncementModel>>((ref) {
  return ref.watch(adminRepositoryProvider).watchAnnouncements();
});

class CreateAnnouncementController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> create({required String title, required String message, required String createdBy}) async {
    state = const AsyncLoading();
    try {
      await ref.read(adminRepositoryProvider).createAnnouncement(title: title, message: message, createdBy: createdBy);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final createAnnouncementControllerProvider =
NotifierProvider<CreateAnnouncementController, AsyncValue<void>>(CreateAnnouncementController.new);