import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../routes/route_names.dart';
import '../../admin/provider/admin_provider.dart';
import '../../auth/provider/auth_provider.dart';
import '../../matches/provider/match_provider.dart';
import '../../matches/widgets/match_card.dart';
import '../../profile/provider/profile_provider.dart';
import '../../wallet/provider/wallet_provider.dart';
import '../../tournaments/provider/tournament_provider.dart';
import '../provider/home_provider.dart';
import '../widgets/banner_slider.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/featured_tournament_card.dart';
import '../widgets/game_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authStateProvider).value?.uid;
    final profileAsync = ref.watch(currentUserProfileProvider);
    final bannersAsync = ref.watch(bannersProvider);
    final tournamentsAsync = ref.watch(liveAndUpcomingTournamentsProvider);
    final gamesAsync = ref.watch(gamesProvider);
    final liveMatches = ref.watch(liveMatchesProvider).value ?? const [];
    final isAdmin = ref.watch(isAdminProvider);
    final quickActions = ref.watch(quickActionsProvider);
    final balanceAsync = uid != null ? ref.watch(walletBalanceProvider(uid)) : null;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(bannersProvider);
            ref.invalidate(tournamentsProvider);
            ref.invalidate(gamesProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _HomeHeader(
                nickname: profileAsync.value?.nickname,
                balance: balanceAsync?.value,
                onNotificationsTap: () => context.push(Routes.notifications),
                onAdminTap: isAdmin ? () => context.push(Routes.adminDashboard) : null,
              ),
              const SizedBox(height: 20),

              bannersAsync.when(
                loading: () => const _SectionLoader(height: 210),
                error: (e, _) => const SizedBox.shrink(),
                data: (banners) => BannerSlider(
                  banners: banners,
                  onJoin: (banner) => _openBanner(context, banner),
                ),
              ),
              const SizedBox(height: 24),

              const _SectionTitle(title: 'Quick Actions'),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: quickActions.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, i) => QuickActionCard(
                  action: quickActions[i],
                  onTap: () => _handleQuickAction(context, quickActions[i]),
                ),
              ),
              const SizedBox(height: 24),

              // Only shown while something is actually live.
              if (liveMatches.isNotEmpty) ...[
                _SectionTitle(
                  title: 'Live Now',
                  onSeeAll: () => context.push(Routes.matches),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 124,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: liveMatches.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, i) => SizedBox(
                      width: 280,
                      child: MatchCard(
                        match: liveMatches[i],
                        onTap: () => context.push(Routes.matchDetailsPath(liveMatches[i].id)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              _SectionTitle(
                title: 'Live & Upcoming',
                onSeeAll: () => context.go(Routes.tournaments),
              ),
              const SizedBox(height: 12),
              tournamentsAsync.when(
                loading: () => const _SectionLoader(height: 190),
                error: (e, _) => const _EmptyRow(message: 'Couldn\'t load tournaments'),
                data: (tournaments) {
                  if (tournaments.isEmpty) {
                    return const _EmptyRow(message: 'No tournaments yet — check back soon');
                  }
                  return SizedBox(
                    height: 190,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: tournaments.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) => FeaturedTournamentCard(
                        tournament: tournaments[i],
                        onTap: () => context.push(Routes.tournamentDetailsPath(tournaments[i].id)),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              const _SectionTitle(title: 'Choose Your Game'),
              const SizedBox(height: 12),
              gamesAsync.when(
                loading: () => const _SectionLoader(height: 140),
                error: (e, _) => const SizedBox.shrink(),
                data: (games) {
                  if (games.isEmpty) return const SizedBox.shrink();
                  return SizedBox(
                    height: 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: games.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, i) => GameCard(game: games[i]),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openBanner(BuildContext context, BannerItem banner) {
    final id = banner.tournamentId;
    if (id != null) {
      context.push(Routes.tournamentDetailsPath(id));
    } else {
      context.go(Routes.tournaments);
    }
  }

  void _handleQuickAction(BuildContext context, QuickAction action) {
    final route = action.route;
    if (route == null) {
      // No screen exists for this yet — say so instead of a silent no-op.
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('${action.label} is coming soon')));
      return;
    }
    // Tabs switch branch (go); everything else stacks on top (push).
    if (Routes.tabRoutes.contains(route)) {
      context.go(route);
    } else {
      context.push(route);
    }
  }
}

class _HomeHeader extends StatelessWidget {
  final String? nickname;
  final num? balance;
  final VoidCallback onNotificationsTap;
  final VoidCallback? onAdminTap;

  const _HomeHeader({this.nickname, this.balance, required this.onNotificationsTap, this.onAdminTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Welcome back', style: TextStyle(color: Color(0xFF9CA0AF), fontSize: 12)),
              const SizedBox(height: 2),
              Text(
                nickname?.isNotEmpty == true ? nickname! : 'Player',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        if (balance != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_balance_wallet, color: AppColors.secondary, size: 14),
                const SizedBox(width: 4),
                Text('₹${balance!.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        if (onAdminTap != null) ...[
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onAdminTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: const Color(0xFF171821), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.admin_panel_settings_outlined, color: AppColors.secondary, size: 20),
            ),
          ),
        ],
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onNotificationsTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: const Color(0xFF171821), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionTitle({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text('See all', style: TextStyle(color: AppColors.secondary, fontSize: 12.5, fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}

class _SectionLoader extends StatelessWidget {
  final double height;
  const _SectionLoader({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondary)),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  final String message;
  const _EmptyRow({required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Center(child: Text(message, style: const TextStyle(color: Color(0xFF9CA0AF), fontSize: 13))),
    );
  }
}