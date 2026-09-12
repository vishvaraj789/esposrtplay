import 'package:flutter/material.dart';

import '../model/tournament_model.dart';

const _kCard = Color(0xFF171821);
const _kHairline = Color(0xFF2A2C38);
const _kTextSecondary = Color(0xFF9CA0AF);
const _kGold = Color(0xFFFFC24B);
const _kGreen = Color(0xFF3DDC84);

class TournamentCard extends StatelessWidget {
  final Tournament tournament;
  final VoidCallback? onTap;

  const TournamentCard({super.key, required this.tournament, this.onTap});

  Color get _statusColor {
    switch (tournament.status) {
      case TournamentStatus.live:
        return const Color(0xFFE23744);
      case TournamentStatus.upcoming:
        return const Color(0xFFFF6A3D);
      case TournamentStatus.completed:
        return _kTextSecondary;
      case TournamentStatus.cancelled:
        return _kTextSecondary;
    }
  }

  String get _statusLabel => tournament.status.name.toUpperCase();

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
                Expanded(
                  child: Text(
                    tournament.name,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: _statusColor, borderRadius: BorderRadius.circular(6)),
                  child: Text(_statusLabel, style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('${tournament.mode.name.toUpperCase()} • ${tournament.map}',
                style: const TextStyle(color: _kTextSecondary, fontSize: 11.5)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.groups, color: _kTextSecondary, size: 14),
                    const SizedBox(width: 4),
                    Text('${tournament.currentParticipants}/${tournament.maxParticipants}',
                        style: const TextStyle(color: _kTextSecondary, fontSize: 11.5)),
                  ],
                ),
                Text('₹${tournament.prizePool.toStringAsFixed(0)} Prize',
                    style: const TextStyle(color: _kGreen, fontSize: 11.5, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}