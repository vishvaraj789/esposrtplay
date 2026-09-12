import 'package:flutter/material.dart';

import '../provider/home_provider.dart';

const _kCard = Color(0xFF171821);
const _kHairline = Color(0xFF2A2C38);
const _kGold = Color(0xFFFFC24B);
const _kTextSecondary = Color(0xFF9CA0AF);
const _kGreen = Color(0xFF3DDC84);

class FeaturedTournamentCard extends StatelessWidget {
  final TournamentItem tournament;
  final VoidCallback? onTap;

  const FeaturedTournamentCard({super.key, required this.tournament, this.onTap});

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
                        color: tournament.badgeColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tournament.badge,
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
                          tournament.time,
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
                      Text(tournament.entry, style: const TextStyle(color: _kTextSecondary, fontSize: 10.5)),
                      Text(
                        tournament.prize,
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