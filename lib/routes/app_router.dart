import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';
import 'route_guard.dart';

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

final routerProvider = Provider<GoRouter>((ref) {
  final refreshStream = GoRouterRefreshStream(
    ref.watch(authRepositoryProvider).authStateChanges,
  );
  ref.onDispose(refreshStream.dispose);

  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: refreshStream,
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
    ],
  );
});

const _authRoutes = {
  Routes.login,
  Routes.register,
  Routes.forgotPassword,
  Routes.otp,
};

FutureOr<String?> _redirect(Ref ref, GoRouterState state) async {
  final location = state.matchedLocation;

  if (location == Routes.splash) return null;

  User? user;
  try {
    user = await ref.read(authStateProvider.future).timeout(const Duration(seconds: 8));
  } catch (_) {
    user = null; // fail safe -> treat as logged out rather than hang
  }

  final isLoggedIn = user != null;
  final isGoingToAuthScreen = _authRoutes.contains(location);

  if (!isLoggedIn && !isGoingToAuthScreen) {
    return Routes.login;
  }

  if (isLoggedIn) {
    if (isGoingToAuthScreen) {
      // Logged in but still landed on an auth screen (e.g. back button) —
      // figure out whether they need onboarding or can go straight home.
      final hasProfile = await UserService.instance.hasProfile(user.uid);
      return hasProfile ? Routes.home : Routes.completeProfile;
    }

    if (location != Routes.completeProfile) {
      final hasProfile = await UserService.instance.hasProfile(user.uid);
      if (!hasProfile) return Routes.completeProfile;
    }
  }

  return null;
}