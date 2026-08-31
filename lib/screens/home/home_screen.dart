import 'package:flutter/material.dart';

/// ============================================================================
/// COLOR TOKENS — matched to the reference mock (dark purple-black canvas,
/// gold for rank/points, purple for profile accent, orange brand CTA).
/// ============================================================================
const kBg = Color(0xFF0B0C12);
const kCard = Color(0xFF171821);
const kHairline = Color(0xFF2A2C38);
const kTextPrimary = Colors.white;
const kTextSecondary = Color(0xFF9CA0AF);
const kPurple = Color(0xFF8B5CF6);
const kGold = Color(0xFFFFC24B);
const kOrange = Color(0xFFFF6A3D);
const kPink = Color(0xFFFF3D5A);
const kGreen = Color(0xFF3DDC84);
const kBlue = Color(0xFF3DA9FC);
const kRed = Color(0xFFE23744);
const kBrandGradient = LinearGradient(
  colors: [kOrange, kPink],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            _buildHeader(context),
            const SizedBox(height: 18),
            _buildGreeting(context),
            const SizedBox(height: 16),
            _buildFeaturedBanner(context),
            const SizedBox(height: 20),
            _buildQuickActionsGrid(context),
            const SizedBox(height: 24),
            _sectionHeader(
                context, 'Live & Upcoming Tournaments', onViewAll: () {}),
            const SizedBox(height: 12),
            _buildTournamentCarousel(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // HEADER — logo wordmark, bell with badge, avatar
  // ============================================================================
  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  children: [
                    TextSpan(
                        text: 'Esport', style: TextStyle(color: kTextPrimary)),
                    TextSpan(text: 'Play', style: TextStyle(color: kOrange)),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Play. Compete. Conquer.',
                style: TextStyle(color: kTextSecondary, fontSize: 12.5),
              ),
            ],
          ),
        ),

        const SizedBox(width: 14),
        GestureDetector(
          onTap: () {
            // TODO: navigate to Profile tab.
          },
          child: Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
                gradient: kBrandGradient, shape: BoxShape.circle),
            child: Container(
              decoration: const BoxDecoration(
                  color: kCard, shape: BoxShape.circle),
              child: const Icon(
                  Icons.face_retouching_natural, color: kTextPrimary, size: 22),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // GREETING
  // ============================================================================
  Widget _buildGreeting(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome back,',
            style: TextStyle(color: kTextSecondary, fontSize: 14)),
        const SizedBox(height: 2),
        Row(
          children: const [
            Text(
              'Vishvrajsinh',
              style: TextStyle(
                  color: kOrange, fontSize: 22, fontWeight: FontWeight.w800),
            ),
            SizedBox(width: 6),
            Text('👋', style: TextStyle(fontSize: 20)),
          ],
        ),
      ],
    );
  }


  Widget _profileStatDivider() =>
      Container(width: 1, height: 30, color: kHairline);

  Widget _profileStat(IconData icon, Color color, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(
                    color: kTextSecondary, fontSize: 10.5)),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: const TextStyle(
                      color: kTextPrimary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // FEATURED TOURNAMENT BANNER
  // ============================================================================
  Widget _buildFeaturedBanner(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 210,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF241934), Color(0xFF3B1F3F), Color(0xFF5A2A2A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                bottom: -10,
                child: Icon(Icons.sports_martial_arts,
                    size: 160, color: Colors.black.withOpacity(0.18)),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'FREE FIRE MAX',
                          style: TextStyle(
                            color: kGold,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: kGreen.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: kGreen.withOpacity(0.5)),
                          ),
                          child: const Text(
                            'REGISTRATION OPEN',
                            style: TextStyle(
                                color: kGreen,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'WEEKLY CHAMPIONSHIP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _bannerChip(Icons.calendar_today, '30 AUG • 8:00 PM'),
                        const SizedBox(width: 8),
                        _bannerChip(Icons.groups, 'BERMUDA • SQUAD'),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('PRIZE POOL',
                                  style: TextStyle(
                                      color: kTextSecondary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              const Text(
                                '₹5,000',
                                style: TextStyle(
                                    color: kGold,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: kBrandGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextButton(
                            onPressed: () {
                              // TODO: navigate to tournament registration.
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('JOIN NOW',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13)),
                                SizedBox(width: 4),
                                Icon(Icons.chevron_right, color: Colors.white,
                                    size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _dot(active: true),
            _dot(active: false),
            _dot(active: false),
          ],
        ),
      ],
    );
  }

  Widget _bannerChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.28),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 12),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _dot({required bool active}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: active ? 16 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active ? kPurple : kHairline,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  // ============================================================================
  // QUICK ACTIONS GRID — 2 rows x 4 cols, colored icon chips
  // ============================================================================
  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      (Icons.emoji_events, kGold, 'Tournaments'),
      (Icons.groups, kGreen, 'My Team'),
      (Icons.search, kBlue, 'Find Players'),
      (Icons.account_balance_wallet, kGold, 'Wallet'),
      (Icons.card_giftcard, kPink, 'Rewards'),
      (Icons.podcasts, kRed, 'Live Match'),
      (Icons.history, kBlue, 'History'),
      (Icons.headset_mic, kPurple, 'Support'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kHairline),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        childAspectRatio: 0.9,
        children: actions.map((a) {
          final (icon, color, label) = a;
          return GestureDetector(
            onTap: () {
              // TODO: route based on label
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: kTextPrimary, fontSize: 10.5),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============================================================================
  // SECTION HEADER — title + "View All"
  // ============================================================================
  Widget _sectionHeader(BuildContext context, String title,
      {required VoidCallback onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                color: kTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        GestureDetector(
          onTap: onViewAll,
          child: Row(
            children: const [
              Text('View All',
                  style: TextStyle(color: kPurple,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700)),
              Icon(Icons.chevron_right, color: kPurple, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // LIVE & UPCOMING TOURNAMENTS — horizontal cards
  // ============================================================================
  Widget _buildTournamentCarousel(BuildContext context) {
    final tournaments = [
      ('Bermuda Clash Squad', 'LIVE', kRed, 'Starts in 45 min', '₹30 Entry', '₹3,000 Prize'),
      ('Kalahari Knockout', 'UPCOMING', kOrange, 'Tomorrow • 6:00 PM', '₹50 Entry', '₹5,500 Prize'),
      ('Solo Survival Cup', 'OPEN', kGreen, '31 Aug • 7:00 PM', '₹20 Entry', '₹2,000 Prize'),
    ];

    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tournaments.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final (name, badge, badgeColor, time, entry, prize) = tournaments[index];
          return Container(
            width: 220,
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kHairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14)),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF241934), Color(0xFF3B1F3F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -6,
                        bottom: -10,
                        child: Icon(Icons.sports_martial_arts,
                            size: 70, color: Colors.black.withOpacity(0.2)),
                      ),
                      Positioned(
                        left: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            color: kTextPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: kGold, size: 12),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(time,
                                style: const TextStyle(
                                    color: kGold, fontSize: 10.5),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry,
                              style: const TextStyle(
                                  color: kTextSecondary, fontSize: 10.5)),
                          Text(prize,
                              style: const TextStyle(
                                  color: kGreen,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}