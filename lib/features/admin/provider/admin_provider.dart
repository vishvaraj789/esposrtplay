import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/admin_config.dart';
import '../../auth/provider/auth_provider.dart';
import '../models/admin_stats_model.dart';
import '../models/announcement_model.dart';
import '../repository/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) => AdminRepository());

/// True only once we've confirmed role == 'admin' on the user doc.
/// Defaults to false while loading or signed out — never fails open.
final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(authStateProvider).value;
  return user?.email?.toLowerCase() == kAdminEmail.toLowerCase();
});

final dashboardStatsProvider = FutureProvider.autoDispose<AdminStats>((ref) {
  return ref.watch(adminRepositoryProvider).fetchDashboardStats();
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