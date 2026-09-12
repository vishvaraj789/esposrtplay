import 'package:flutter/material.dart';

import '../model/tournament_model.dart';

const _kCard = Color(0xFF171821);
const _kHairline = Color(0xFF2A2C38);
const _kTextSecondary = Color(0xFF9CA0AF);
const _kGreen = Color(0xFF3DDC84);

/// Renders a single-elimination bracket as horizontally scrollable
/// rounds, each a vertical column of match cards.
class BracketWidget extends StatelessWidget {
  final List<MatchModel> matches;
  final void Function(MatchModel match)? onMatchTap;

  const BracketWidget({super.key, required this.matches, this.onMatchTap});

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return const Center(
        child: Text('Bracket not generated yet', style: TextStyle(color: _kTextSecondary)),
      );
    }

    final rounds = <int, List<MatchModel>>{};
    for (final m in matches) {
      rounds.putIfAbsent(m.round, () => []).add(m);
    }
    final roundNumbers = rounds.keys.toList()..sort();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: roundNumbers.map((round) {
          final roundMatches = rounds[round]!..sort((a, b) => a.matchIndex.compareTo(b.matchIndex));
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Round $round', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                ...roundMatches.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MatchCard(match: m, onTap: onMatchTap == null ? null : () => onMatchTap!(m)),
                )),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final MatchModel match;
  final VoidCallback? onTap;

  const _MatchCard({required this.match, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kHairline),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            _row(match.teamAName, match.scoreA, match.winnerTeamId == match.teamAId),
            const Divider(color: _kHairline, height: 12),
            _row(match.teamBName, match.scoreB, match.winnerTeamId == match.teamBId),
          ],
        ),
      ),
    );
  }

  Widget _row(String name, int? score, bool isWinner) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              color: isWinner ? _kGreen : Colors.white,
              fontSize: 12,
              fontWeight: isWinner ? FontWeight.w700 : FontWeight.w400,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(score?.toString() ?? '-', style: const TextStyle(color: _kTextSecondary, fontSize: 12)),
      ],
    );
  }
}