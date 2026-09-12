import 'package:flutter/material.dart';

/// ============================================================================
/// COLOR TOKENS — kept consistent with HomeScreen / TournamentsScreen.
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
const kBrandGradient = LinearGradient(
  colors: [kOrange, kPink],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

class _Member {
  final String name;
  final String role;
  final Color color;
  final bool isCaptain;
  const _Member(this.name, this.role, this.color, {this.isCaptain = false});
}

/// Create a team, join a team, or manage squad members.
class TeamsScreen extends StatelessWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Demo: user is currently on a team. Swap for a real Firestore check.
    final bool hasTeam = true;

    final members = const [
      _Member('Vishvrajsinh', 'Nader / IGL', kPurple, isCaptain: true),
      _Member('ShadowStrike99', 'Rusher', kOrange),
      _Member('DarkHunter', 'Secondary Rusher', kBlue),
      _Member('RDX Killer', 'Support', kGreen),
    ];

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: hasTeam ? _buildTeamView(context, members) : _buildEmptyState(context),
      ),
    );
  }

  // ============================================================================
  // HEADER
  // ============================================================================
  Widget _buildHeader(BuildContext context, {Widget? action}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Teams',
                  style: TextStyle(
                      color: kTextPrimary, fontSize: 26, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text('Squad up. Sync up. Win.',
                  style: TextStyle(color: kTextSecondary, fontSize: 13)),
            ],
          ),
        ),
        if (action != null) action,
      ],
    );
  }

  // ============================================================================
  // HAS-TEAM VIEW
  // ============================================================================
  Widget _buildTeamView(BuildContext context, List<_Member> members) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _buildHeader(
          context,
          action: GestureDetector(
            onTap: () {
              // TODO: open invite sheet (share invite code / link).
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: kCard, shape: BoxShape.circle),
              child: const Icon(Icons.person_add_alt_1, color: kTextPrimary, size: 20),
            ),
          ),
        ),
        const SizedBox(height: 18),
        _buildTeamCard(context, members),
        const SizedBox(height: 16),
        _buildStatsRow(context),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Squad Members',
                style: const TextStyle(
                    color: kTextPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
            Text('${members.length}/4', style: TextStyle(color: kTextSecondary, fontSize: 12.5)),
          ],
        ),
        const SizedBox(height: 12),
        ...members.map((m) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildMemberTile(context, m),
        )),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: leave-team confirmation flow.
            },
            icon: const Icon(Icons.logout, color: kTextSecondary, size: 18),
            label: const Text('Leave Team',
                style: TextStyle(color: kTextSecondary, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 13),
              side: BorderSide(color: kHairline),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // TEAM IDENTITY CARD — crest, name, tag
  // ============================================================================
  Widget _buildTeamCard(BuildContext context, List<_Member> members) {
    return Container(
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPurple.withOpacity(0.45)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: kBrandGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.shield, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('ESP Warriors',
                        style: TextStyle(
                            color: kTextPrimary, fontSize: 17, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: kGreen.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('CAPTAIN',
                          style: TextStyle(
                              color: kGreen, fontSize: 9, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${members.length} / 4 members · Tag: ESPW',
                    style: TextStyle(color: kTextSecondary, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: kTextSecondary),
        ],
      ),
    );
  }

  // ============================================================================
  // STATS ROW — team-level performance
  // ============================================================================
  Widget _buildStatsRow(BuildContext context) {
    final stats = [
      ('Matches', '38'),
      ('Wins', '14'),
      ('Win Rate', '37%'),
      ('Rank', '#128'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kHairline),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: List.generate(stats.length, (i) {
          final (label, value) = stats[i];
          return Expanded(
            child: Row(
              children: [
                if (i > 0) Container(width: 1, height: 26, color: kHairline),
                Expanded(
                  child: Column(
                    children: [
                      Text(value,
                          style: const TextStyle(
                              color: kGold, fontSize: 15, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text(label, style: TextStyle(color: kTextSecondary, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ============================================================================
  // MEMBER TILE — avatar, name, role badge, captain crown
  // ============================================================================
  Widget _buildMemberTile(BuildContext context, _Member m) {
    return Container(
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kHairline),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: m.color, shape: BoxShape.circle),
            child: const Icon(Icons.face, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(m.name,
                        style: const TextStyle(
                            color: kTextPrimary, fontSize: 13.5, fontWeight: FontWeight.w700)),
                    if (m.isCaptain) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.workspace_premium, color: kGold, size: 14),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(m.role, style: TextStyle(color: kTextSecondary, fontSize: 11.5)),
              ],
            ),
          ),
          if (!m.isCaptain)
            GestureDetector(
              onTap: () {
                // TODO: open member options (message, remove, transfer captain).
              },
              child: const Icon(Icons.more_vert, color: kTextSecondary, size: 18),
            ),
        ],
      ),
    );
  }

  // ============================================================================
  // EMPTY STATE — no team yet
  // ============================================================================
  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const Spacer(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: kCard,
                    shape: BoxShape.circle,
                    border: Border.all(color: kHairline),
                  ),
                  child: const Icon(Icons.groups_outlined, color: kTextSecondary, size: 36),
                ),
                const SizedBox(height: 16),
                const Text('You are not on a team yet',
                    style: TextStyle(
                        color: kTextPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                  'Create your own squad or join one with an invite code.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: kTextSecondary, fontSize: 12.5),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: kBrandGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton.icon(
                onPressed: () {
                  // TODO: navigate to create-team flow.
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Create a Team',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: navigate to join-team flow (e.g. via invite code).
              },
              icon: const Icon(Icons.login, color: kPurple),
              label: const Text('Join a Team',
                  style: TextStyle(color: kPurple, fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: kPurple, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}