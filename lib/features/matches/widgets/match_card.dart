import 'package:flutter/material.dart';

import '../models/match_model.dart';
import 'match_status_chip.dart';

const _kCard = Color(0xFF171821);
const _kHairline = Color(0xFF2A2C38);
const _kTextSecondary = Color(0xFF9CA0AF);
const _kGreen = Color(0xFF3DDC84);

class MatchCard extends StatelessWidget {
  final MatchModel match;
  final VoidCallback? onTap;

  const MatchCard({super.key, required this.match, this.onTap});

  String _formatTime(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.hour >= 12 ? 'PM' : 'AM';
    return '${t.day}/${t.month} · $h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kHairline),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Round ${match.round} · ${match.map}',
                    style: const TextStyle(color: _kTextSecondary, fontSize: 11.5)),
                MatchStatusChip(status: match.status),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    match.teamAName,
                    style: TextStyle(
                      color: match.winnerId == match.teamAId ? _kGreen : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('VS', style: TextStyle(color: _kTextSecondary, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
                Expanded(
                  child: Text(
                    match.teamBName,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: match.winnerId == match.teamBId ? _kGreen : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(_formatTime(match.scheduledAt), style: const TextStyle(color: _kTextSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}