import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';
import 'placeholder_screen.dart';

import '../core/services/user_service.dart';

import '../features/auth/provider/auth_provider.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/otp_screen.dart';

import '../features/profile/widgets/user_form.dart';

import '../features/navigation/main_navigation.dart';
import '../features/splash/presentation/splash_screen.dart';

import '../features/leaderboard/presentation/leaderboard_screen.dart';

import '../features/wallet/presentation/wallet_screen.dart';
import '../features/wallet/presentation/transaction_screen.dart';
import '../features/wallet/presentation/withdraw_screen.dart';

import '../features/notifications/presentation/notifications_screen.dart';

import '../features/chat/presentation/chat_screen.dart';
import '../features/chat/presentation/team_chat_screen.dart';

import '../features/admin/presentation/admin_dashboard_screen.dart';
import '../features/admin/presentation/admin_tournaments_screen.dart';
import '../features/admin/presentation/admin_tournament_form_screen.dart';
import '../features/admin/presentation/admin_teams_screen.dart';
import '../features/admin/presentation/admin_matches_screen.dart';
import '../features/admin/presentation/admin_match_create_screen.dart';
import '../features/admin/presentation/admin_match_manage_screen.dart';
import '../features/admin/presentation/admin_announcements_screen.dart';

import '../features/matches/presentation/matches_screen.dart';
import '../features/matches/presentation/match_details_screen.dart';
import '../features/matches/presentation/match_room_screen.dart';
import '../features/matches/presentation/match_result_screen.dart';

import '../features/tournaments/presentation/tournament_details_screen.dart';
import '../features/teams/presentation/team_create_screen.dart';
import '../features/teams/presentation/team_details_screen.dart';
import '../features/admin/repository/admin_repository.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier();

  ref.listen<AsyncValue<User?>>(authStateProvider, (previous, next) {
    debugPrint('[redirect] authStateProvider changed: ${next.value?.uid}');
    refreshNotifier.notify();
  });
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) => _redirect(ref, state),
    routes: [
      GoRoute(path: Routes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: Routes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: Routes.register, builder: (_, __) => const RegisterScreen()),
      GoRoute(path: Routes.forgotPassword, builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(
        path: Routes.otp,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return OtpScreen(
            phoneNumber: extra['phoneNumber'] as String? ?? '',
            verificationId: extra['verificationId'] as String? ?? '',
          );
        },
      ),
      GoRoute(path: Routes.completeProfile, builder: (_, __) => const UserForm()),

      GoRoute(path: Routes.home, builder: (_, __) => const MainNavigation()),

      GoRoute(path: Routes.leaderboard, builder: (_, __) => const LeaderboardScreen()),

      GoRoute(path: Routes.wallet, builder: (_, __) => const WalletScreen()),
      GoRoute(path: Routes.walletTransactions, builder: (_, __) => const TransactionScreen()),
      GoRoute(path: Routes.walletWithdraw, builder: (_, __) => const WithdrawScreen()),

      GoRoute(path: Routes.notifications, builder: (_, __) => const NotificationsScreen()),

      GoRoute(
        path: Routes.chat,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ChatScreen(
            otherUid: extra['otherUid'] as String? ?? '',
            otherUserName: extra['otherUserName'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: Routes.teamChat,
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return TeamChatScreen(
            teamId: extra['teamId'] as String? ?? '',
            teamName: extra['teamName'] as String? ?? '',
          );
        },
      ),

      // ---- Tournaments (static 'create' before ':id') ----
      GoRoute(path: Routes.tournamentCreate, builder: (_, __) => const RoutePlaceholderScreen(title: 'Create Tournament')),
      GoRoute(
        path: Routes.tournamentDetails,
        builder: (_, state) => TournamentDetailsScreen(tournamentId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: Routes.tournamentBracket,
        builder: (_, state) => RoutePlaceholderScreen(title: 'Tournament Bracket', details: 'id: ${state.pathParameters['id']}'),
      ),

      // ---- Matches ----
      GoRoute(path: Routes.matches, builder: (_, __) => const MatchesScreen()),
      GoRoute(
        path: Routes.matchDetails,
        builder: (_, state) => MatchDetailsScreen(matchId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: Routes.matchRoom,
        builder: (_, state) => MatchRoomScreen(matchId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: Routes.matchResult,
        builder: (_, state) => MatchResultScreen(matchId: state.pathParameters['id']!),
      ),

      // ---- Teams (static 'create' before ':id') ----
      GoRoute(path: Routes.teamCreate, builder: (_, __) => const TeamCreateScreen()),
      GoRoute(
        path: Routes.teamDetails,
        builder: (_, state) => TeamDetailsScreen(teamId: state.pathParameters['id']!),
      ),

      // ---- Profile ----
      GoRoute(path: Routes.profileEdit, builder: (_, __) => const RoutePlaceholderScreen(title: 'Edit Profile')),
      GoRoute(path: Routes.profileAchievements, builder: (_, __) => const RoutePlaceholderScreen(title: 'Achievements')),

      // ---- Admin (guarded by the /admin prefix check in _redirect) ----
      GoRoute(path: Routes.adminDashboard, builder: (_, __) => const AdminDashboardScreen()),
      GoRoute(path: Routes.adminTournaments, builder: (_, __) => const AdminTournamentsScreen()),
      GoRoute(
        path: Routes.adminTournamentEdit,
        builder: (_, state) => AdminTournamentFormScreen(tournamentId: state.pathParameters['id']!),
      ),
      GoRoute(path: Routes.adminTeams, builder: (_, __) => const AdminTeamsScreen()),
      GoRoute(path: Routes.adminMatches, builder: (_, __) => const AdminMatchesScreen()),
      GoRoute(path: Routes.adminMatchCreate, builder: (_, __) => const AdminMatchCreateScreen()),
      GoRoute(
        path: Routes.adminMatchManage,
        builder: (_, state) => AdminMatchManageScreen(matchId: state.pathParameters['id']!),
      ),
      GoRoute(path: Routes.adminAnnouncements, builder: (_, __) => const AdminAnnouncementsScreen()),
    ],
  );
});

const _authRoutes = {
  Routes.login,
  Routes.register,
  Routes.forgotPassword,
  Routes.otp,
};

/// Checks whether the user finished the UserForm step. If Firestore can't be
/// reached (offline / rules), returns false so the user lands on the form —
/// UserForm safely forwards existing users to home instead of overwriting.
Future<bool> _profileComplete(String uid) async {
  try {
    final result = await UserService.instance.hasProfile(uid);
    debugPrint('[profile] hasProfile($uid) = $result');
    return result;
  } catch (e) {
    debugPrint('[profile] hasProfile($uid) threw: $e');
    return false;
  }
}

/// Checks the signed-in user's role for admin-only routes. Fails closed
/// (denies access) on any error rather than hanging or leaking admin UI.
Future<bool> _isAdmin(String uid) async {
  try {
    final result = await AdminRepository().watchIsAdmin(uid).first.timeout(const Duration(seconds: 8));
    debugPrint('[admin] isAdmin($uid) = $result');
    return result;
  } catch (e) {
    debugPrint('[admin] isAdmin($uid) threw: $e');
    return false;
  }
}

FutureOr<String?> _redirect(Ref ref, GoRouterState state) async {
  final location = state.matchedLocation;
  debugPrint('[redirect] location: $location');

  if (location == Routes.splash) return null;

  User? user;
  try {
    user = await ref.read(authStateProvider.future).timeout(const Duration(seconds: 8));
  } catch (_) {
    user = null; // fail safe -> treat as logged out rather than hang
  }
  debugPrint('[redirect] user: ${user?.uid}');

  // Not logged in: only auth screens are reachable.
  if (user == null) {
    final target = _authRoutes.contains(location) ? null : Routes.login;
    debugPrint('[redirect] not logged in -> $target');
    return target;
  }

  final hasProfile = await _profileComplete(user.uid);

  // Logged in, profile incomplete: force the UserForm.
  if (!hasProfile) {
    final target = location == Routes.completeProfile ? null : Routes.completeProfile;
    debugPrint('[redirect] no profile -> $target');
    return target;
  }

  // Logged in, profile complete: keep them out of auth screens and the form.
  if (_authRoutes.contains(location) || location == Routes.completeProfile) {
    debugPrint('[redirect] has profile, on auth/form screen -> home');
    return Routes.home;
  }

  // Admin guard: bounce non-admins away from /admin entirely.
  if (location.startsWith('/admin')) {
    final isAdmin = await _isAdmin(user.uid);
    if (!isAdmin) {
      debugPrint('[redirect] not admin, blocked from $location -> home');
      return Routes.home;
    }
  }

  debugPrint('[redirect] no redirect needed, staying at $location');
  return null;
}

/// Re-runs the router redirect whenever authStateProvider changes.
/// Deliberately has no stream subscription of its own — it piggybacks on
/// authStateProvider (via ref.listen in routerProvider) rather than
/// building a second, independent FirebaseAuth.authStateChanges() stream,
/// which previously caused the two to desync.
class _AuthRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
