import 'package:flutter/material.dart';

const _kCard = Color(0xFF171821);
const _kHairline = Color(0xFF2A2C38);
const _kGold = Color(0xFFFFC24B);
const _kTextSecondary = Color(0xFF9CA0AF);

class StatsCard extends StatelessWidget {
  final int matches;
  final int wins;
  final int rank;

  const StatsCard({super.key, required this.matches, required this.wins, required this.rank});

  @override
  Widget build(BuildContext context) {
    final winRate = matches == 0 ? '0%' : '${((wins / matches) * 100).toStringAsFixed(0)}%';
    final stats = [
      ('Matches', matches.toString()),
      ('Wins', wins.toString()),
      ('Win Rate', winRate),
      ('Rank', rank > 0 ? '#$rank' : '—'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kHairline),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: List.generate(stats.length, (i) {
          final (label, value) = stats[i];
          return Expanded(
            child: Row(
              children: [
                if (i > 0) Container(width: 1, height: 26, color: _kHairline),
                Expanded(
                  child: Column(
                    children: [
                      Text(value, style: const TextStyle(color: _kGold, fontSize: 15, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text(label, style: const TextStyle(color: _kTextSecondary, fontSize: 10)),
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
} 