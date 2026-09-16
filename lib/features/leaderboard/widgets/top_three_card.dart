import 'package:flutter/material.dart';

import '../../tournaments/model/tournament_model.dart';

const _kCard = Color(0xFF171821);
const _kHairline = Color(0xFF2A2C38);
const _kGold = Color(0xFFFFC24B);
const _kSilver = Color(0xFFC0C6D4);
const _kBronze = Color(0xFFCD7F32);
const _kTextSecondary = Color(0xFF9CA0AF);

/// Podium display for ranks 1–3. Expects [entries] already sorted by rank
/// and containing at least the top 3 (fewer than 3 renders the ones present).
class TopThreeCard extends StatelessWidget {
  final List<LeaderboardEntry> entries;

  const TopThreeCard({super.key, required this.entries});

  LeaderboardEntry? _at(int rank) {
    for (final e in entries) {
      if (e.rank == rank) return e;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final first = _at(1);
    final second = _at(2);
    final third = _at(3);

    if (first == null && second == null && third == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kHairline),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _podiumSlot(second, height: 78, color: _kSilver, icon: Icons.military_tech),
          _podiumSlot(first, height: 104, color: _kGold, icon: Icons.emoji_events),
          _podiumSlot(third, height: 60, color: _kBronze, icon: Icons.workspace_premium),
        ],
      ),
    );
  }

  Widget _podiumSlot(LeaderboardEntry? entry, {required double height, required Color color, required IconData icon}) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: entry == null ? _kTextSecondary : color, size: 26),
          const SizedBox(height: 6),
          Text(
            entry?.teamName ?? '—',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            entry != null ? '${entry.points} pts' : '',
            style: const TextStyle(color: _kTextSecondary, fontSize: 10.5),
          ),
          const SizedBox(height: 8),
          Container(
            height: height,
            decoration: BoxDecoration(
              color: (entry == null ? _kTextSecondary : color).withOpacity(0.18),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              border: Border.all(color: (entry == null ? _kTextSecondary : color).withOpacity(0.4)),
            ),
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              entry != null ? '#${entry.rank}' : '-',
              style: TextStyle(color: entry == null ? _kTextSecondary : color, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}