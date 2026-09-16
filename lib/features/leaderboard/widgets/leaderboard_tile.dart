import 'package:flutter/material.dart';

import '../../tournaments/model/tournament_model.dart';

const _kCard = Color(0xFF171821);
const _kHairline = Color(0xFF2A2C38);
const _kTextSecondary = Color(0xFF9CA0AF);
const _kGreen = Color(0xFF3DDC84);

/// Row for ranks 4+ (top 3 are shown via TopThreeCard instead).
class LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUserTeam;

  const LeaderboardTile({super.key, required this.entry, this.isCurrentUserTeam = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isCurrentUserTeam ? _kGreen : _kHairline),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '#${entry.rank}',
              style: const TextStyle(color: _kTextSecondary, fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Text(
              entry.teamName,
              style: TextStyle(
                color: isCurrentUserTeam ? _kGreen : Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text('${entry.points} pts', style: const TextStyle(color: _kTextSecondary, fontSize: 12.5)),
        ],
      ),
    );
  }
}