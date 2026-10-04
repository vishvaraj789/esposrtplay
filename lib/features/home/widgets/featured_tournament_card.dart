import 'package:flutter/material.dart';

import '../../tournaments/model/tournament_model.dart';

const _kCard = Color(0xFF171821);
const _kHairline = Color(0xFF2A2C38);
const _kGold = Color(0xFFFFC24B);
const _kTextSecondary = Color(0xFF9CA0AF);
const _kGreen = Color(0xFF3DDC84);
const _kRed = Color(0xFFE23744);
const _kOrange = Color(0xFFFF6A3D);

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _startLabel(DateTime start) {
  final local = start.toLocal();
  final now = DateTime.now();
  final days = DateTime(local.year, local.month, local.day)
      .difference(DateTime(now.year, now.month, now.day))
      .inDays;
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final clock = '$hour:${local.minute.toString().padLeft(2, '0')} ${local.hour >= 12 ? 'PM' : 'AM'}';
  if (days == 0) return 'Today, $clock';
  if (days == 1) return 'Tomorrow, $clock';
  return '${local.day} ${_months[local.month - 1]}, $clock';
}

class FeaturedTournamentCard extends StatelessWidget {
  final Tournament tournament;
  final VoidCallback? onTap;

  const FeaturedTournamentCard({super.key, required this.tournament, this.onTap});

  // Display values are derived from the real model — nothing here depends on
  // extra presentation fields existing in Firestore.
  String get _badge {
    switch (tournament.status) {
      case TournamentStatus.live:
        return 'LIVE';
      case TournamentStatus.upcoming:
        return tournament.isFull ? 'FULL' : 'OPEN';
      case TournamentStatus.completed:
        return 'ENDED';
      case TournamentStatus.cancelled:
        return 'CANCELLED';
    }
  }

  Color get _badgeColor {
    switch (tournament.status) {
      case TournamentStatus.live:
        return _kRed;
      case TournamentStatus.upcoming:
        return tournament.isFull ? _kOrange : _kGreen;
      case TournamentStatus.completed:
      case TournamentStatus.cancelled:
        return _kTextSecondary;
    }
  }

  String get _timeLabel =>
      tournament.status == TournamentStatus.live ? 'Live now' : _startLabel(tournament.startTime);

  String get _entryLabel =>
      tournament.entryFee == 0 ? 'Free entry' : '₹${tournament.entryFee.toStringAsFixed(0)} entry';

  String get _prizeLabel => '₹${tournament.prizePool.toStringAsFixed(0)} Prize';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kHairline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
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
                    child: Icon(Icons.sports_martial_arts, size: 70, color: Colors.black.withOpacity(0.2)),
                  ),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _badgeColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _badge,
                        style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800),
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
                    tournament.name,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: _kGold, size: 12),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _timeLabel,
                          style: const TextStyle(color: _kGold, fontSize: 10.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_entryLabel, style: const TextStyle(color: _kTextSecondary, fontSize: 10.5)),
                      Text(
                        _prizeLabel,
                        style: const TextStyle(color: _kGreen, fontSize: 10.5, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}