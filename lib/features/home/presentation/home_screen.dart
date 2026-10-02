import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../routes/route_names.dart';
import '../../auth/provider/auth_provider.dart';
import '../../profile/provider/profile_provider.dart';
import '../../wallet/provider/wallet_provider.dart';
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
    final tournamentsAsync = ref.watch(tournamentsProvider);
    final gamesAsync = ref.watch(gamesProvider);
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
              ),
              const SizedBox(height: 20),

              bannersAsync.when(
                loading: () => const _SectionLoader(height: 210),
                error: (e, _) => const SizedBox.shrink(),
                data: (banners) => BannerSlider(banners: banners),
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
                  onTap: () => _handleQuickAction(context, quickActions[i].label),
                ),
              ),
              const SizedBox(height: 24),

              _SectionTitle(
                title: 'Live & Upcoming',
                onSeeAll: () => context.push(Routes.wallet /* TODO: Routes.tournaments once wired */),
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
                        onTap: () {
                          // TODO: push tournament_details_screen.dart once
                          // it exists and is wired into app_router.dart.
                        },
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

  void _handleQuickAction(BuildContext context, String label) {
    switch (label) {
      case 'Tournaments':
      // TODO: context.push(Routes.tournaments) once that route exists.
        break;
      case 'Wallet':
        context.push(Routes.wallet);
        break;
      case 'Live Match':
      // TODO: push live_match_screen.dart once wired.
        break;
      default:
        break;
    }
  }
}

class _HomeHeader extends StatelessWidget {
  final String? nickname;
  final num? balance;
  final VoidCallback onNotificationsTap;

  const _HomeHeader({this.nickname, this.balance, required this.onNotificationsTap});

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