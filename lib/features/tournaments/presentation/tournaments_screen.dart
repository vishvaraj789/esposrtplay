import 'package:flutter/material.dart';

/// ============================================================================
/// COLOR TOKENS — kept consistent with HomeScreen's dark palette.
/// ============================================================================
const kBg = Color(0xFF0B0C12);
const kCard = Color(0xFF171821);
const kChip = Color(0xFF1D1E29);
const kHairline = Color(0xFF2A2C38);
const kTextPrimary = Colors.white;
const kTextSecondary = Color(0xFF9CA0AF);
const kPurple = Color(0xFF8B5CF6);
const kGold = Color(0xFFFFC24B);
const kOrange = Color(0xFFFF6A3D);
const kGreen = Color(0xFF3DDC84);

enum _TournamentStatus { live, upcoming, completed }

class _Tournament {
  final String name;
  final _TournamentStatus status;
  final String mode;
  final String map;
  final String date;
  final String teams;
  final String entryFee;
  final String prizePool;
  final List<Color> artGradient;
  const _Tournament({
    required this.name,
    required this.status,
    required this.mode,
    required this.map,
    required this.date,
    required this.teams,
    required this.entryFee,
    required this.prizePool,
    required this.artGradient,
  });
}

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  int _tabIndex = 0; // Live / Upcoming / My Tournaments / Completed
  int _filterIndex = 0; // All / Squad / Duo / Solo / Clash Squad / Bermuda

  final _tabs = const ['Live', 'Upcoming', 'Completed'];
  final _filters = const [
    ('All', null),
    ('Squad', Icons.groups),
    ('Duo', Icons.person_outline),
    ('Solo', Icons.person),
    ('Clash Squad', Icons.gps_fixed),
    ('Bermuda', Icons.terrain),
  ];

  final _tournaments = const [
    _Tournament(
      name: 'Weekly Clash Championship',
      status: _TournamentStatus.live,
      mode: 'Squad',
      map: 'Bermuda',
      date: '30 Aug, 8:00 PM',
      teams: '32 / 48 Teams',
      entryFee: '₹50',
      prizePool: '₹5,000',
      artGradient: [Color(0xFF241934), Color(0xFF3B1F3F)],
    ),
    _Tournament(
      name: 'Clash Squad Showdown',
      status: _TournamentStatus.live,
      mode: 'Clash Squad',
      map: 'Kalahari',
      date: '29 Aug, 6:00 PM',
      teams: '20 / 32 Teams',
      entryFee: 'Free',
      prizePool: '₹1,000',
      artGradient: [Color(0xFF4A2A12), Color(0xFF7A3A12)],
    ),
    _Tournament(
      name: 'Night Hunters',
      status: _TournamentStatus.live,
      mode: 'Duo',
      map: 'Bermuda',
      date: '29 Aug, 9:00 PM',
      teams: '18 / 32 Teams',
      entryFee: '₹20',
      prizePool: '₹2,000',
      artGradient: [Color(0xFF10151F), Color(0xFF1E2A3A)],
    ),
    _Tournament(
      name: 'Bermuda Battle Cup',
      status: _TournamentStatus.upcoming,
      mode: 'Squad',
      map: 'Bermuda',
      date: '31 Aug, 7:00 PM',
      teams: '10 / 48 Teams',
      entryFee: '₹30',
      prizePool: '₹3,000',
      artGradient: [Color(0xFF2B3A4A), Color(0xFF456075)],
    ),
    _Tournament(
      name: 'Kalahari Knockout',
      status: _TournamentStatus.upcoming,
      mode: 'Duo',
      map: 'Kalahari',
      date: '01 Sep, 6:00 PM',
      teams: '7 / 32 Teams',
      entryFee: '₹40',
      prizePool: '₹4,000',
      artGradient: [Color(0xFF3A2140), Color(0xFF5A2F5A)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Filter by active top tab (Live vs Upcoming); My Tournaments/Completed
    // are left as empty states for now since there's no data source yet.
    final visible = _tabIndex == 0
        ? _tournaments.where((t) => t.status == _TournamentStatus.live).toList()
        : _tabIndex == 1
        ? _tournaments.where((t) => t.status == _TournamentStatus.upcoming).toList()
        : _tournaments.where((t) => t.status == _TournamentStatus.completed).toList();

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _buildHeader(context),
            ),
            const SizedBox(height: 14),
            _buildTabs(context),
            const SizedBox(height: 14),
            _buildFilterChips(context),
            const SizedBox(height: 14),
            Expanded(
              child: visible.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                itemCount: visible.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) => _buildTournamentCard(context, visible[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // HEADER
  // ============================================================================
  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tournaments',
                  style: TextStyle(
                      color: kTextPrimary, fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text('Compete. Dominate. Win.',
                  style: TextStyle(color: kTextSecondary, fontSize: 13)),
            ],
          ),
        ),
        _iconButton(Icons.search, () {
          // TODO: open tournament search
        }),
        const SizedBox(width: 10),
        _iconButton(Icons.tune, () {
          // TODO: open filter sheet
        }),
      ],
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: Icon(icon, color: kTextPrimary, size: 22),
      ),
    );
  }

  // ============================================================================
  // STATUS TABS — Live / Upcoming / My Tournaments / Completed
  // ============================================================================
  Widget _buildTabs(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final isActive = i == _tabIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tabIndex = i),
              child: Column(
                children: [
                  Text(
                    _tabs[i].toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isActive ? kPurple : kTextSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 2,
                    color: isActive ? kPurple : Colors.transparent,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ============================================================================
  // FILTER CHIPS — mode/map quick filters
  // ============================================================================
  Widget _buildFilterChips(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (label, icon) = _filters[index];
          final isActive = index == _filterIndex;
          return GestureDetector(
            onTap: () => setState(() => _filterIndex = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isActive ? kPurple : kChip,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isActive ? kPurple : kHairline),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 14, color: isActive ? Colors.white : kTextSecondary),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      color: isActive ? Colors.white : kTextSecondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================================
  // TOURNAMENT CARD
  // ============================================================================
  Widget _buildTournamentCard(BuildContext context, _Tournament t) {
    final isLive = t.status == _TournamentStatus.live;
    final badgeColor = isLive ? kGreen : kOrange;
    final badgeLabel = isLive ? 'LIVE' : 'UPCOMING';

    return Container(
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kHairline),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Art thumbnail with status badge
          Stack(
            children: [
              Container(
                width: 108,
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: t.artGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -8,
                      bottom: -6,
                      child: Icon(Icons.sports_martial_arts,
                          size: 90, color: Colors.black.withOpacity(0.22)),
                    ),
                    Positioned(
                      left: 6,
                      right: 6,
                      bottom: 8,
                      child: Text(
                        t.name.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(badgeLabel,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.name,
                  style: const TextStyle(
                      color: kTextPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _metaChip(Icons.groups, t.mode),
                    const SizedBox(width: 14),
                    _metaChip(Icons.terrain, t.map),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 13, color: kTextSecondary),
                    const SizedBox(width: 6),
                    Text(t.date, style: TextStyle(color: kTextSecondary, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.people_outline, size: 13, color: kTextSecondary),
                    const SizedBox(width: 6),
                    Text(t.teams, style: TextStyle(color: kTextSecondary, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(color: kHairline, height: 1),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ENTRY FEE',
                              style: TextStyle(
                                  color: kTextSecondary,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 3),
                          Text(t.entryFee,
                              style: TextStyle(
                                  color: t.entryFee == 'Free' ? kGreen : kGold,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PRIZE POOL',
                              style: TextStyle(
                                  color: kTextSecondary,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 3),
                          Text(t.prizePool,
                              style: const TextStyle(
                                  color: kGreen, fontSize: 14, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: isLive
                      ? ElevatedButton(
                    onPressed: () {
                      // TODO: join tournament flow
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPurple,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('JOIN NOW',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5)),
                  )
                      : OutlinedButton(
                    onPressed: () {
                      // TODO: view tournament details
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kPurple, width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('VIEW DETAILS',
                        style: TextStyle(
                            color: kPurple,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: kPurple),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: kTextPrimary, fontSize: 12)),
      ],
    );
  }

  // ============================================================================
  // EMPTY STATE — for My Tournaments / Completed until wired to real data
  // ============================================================================
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events_outlined, color: kTextSecondary, size: 40),
            const SizedBox(height: 12),
            Text(
              'Nothing here yet',
              style: TextStyle(color: kTextPrimary, fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Your completed tournaments will show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kTextSecondary, fontSize: 12.5),
            ),
          ],
        ),
      ),
    );
  }
}