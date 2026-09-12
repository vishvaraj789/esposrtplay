import 'package:flutter/material.dart';

const _kCard = Color(0xFF171821);
const _kHairline = Color(0xFF2A2C38);
const _kGold = Color(0xFFFFC24B);
const _kTextSecondary = Color(0xFF9CA0AF);

class PrizeCard extends StatelessWidget {
  final Map<String, double> breakdown; // ordered: {"1st": x, "2nd": y, ...}

  const PrizeCard({super.key, required this.breakdown});

  IconData _iconFor(String place) {
    switch (place) {
      case '1st':
        return Icons.emoji_events;
      case '2nd':
        return Icons.military_tech;
      default:
        return Icons.workspace_premium;
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = breakdown.entries.toList();

    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kHairline),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Prize Breakdown', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...entries.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(_iconFor(e.key), color: _kGold, size: 18),
                const SizedBox(width: 8),
                Text(e.key, style: const TextStyle(color: _kTextSecondary, fontSize: 13)),
                const Spacer(),
                Text('₹${e.value.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}