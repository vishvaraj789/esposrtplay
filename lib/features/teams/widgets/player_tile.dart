import 'package:flutter/material.dart';

import '../repository/team_repository.dart';
import 'captain_badge.dart';

const _kCard = Color(0xFF171821);
const _kHairline = Color(0xFF2A2C38);
const _kTextPrimary = Colors.white;
const _kTextSecondary = Color(0xFF9CA0AF);
const _kBlue = Color(0xFF3DA9FC);

class PlayerTile extends StatelessWidget {
  final TeamMember member;
  final bool showMoreMenu;
  final VoidCallback? onMoreTap;

  const PlayerTile({
    super.key,
    required this.member,
    this.showMoreMenu = false,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kHairline),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(color: _kBlue, shape: BoxShape.circle),
            child: const Icon(Icons.face, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(member.name,
                        style: const TextStyle(color: _kTextPrimary, fontSize: 13.5, fontWeight: FontWeight.w700)),
                    if (member.isCaptain) ...[
                      const SizedBox(width: 6),
                      const CaptainBadge(asPill: false),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(member.role, style: const TextStyle(color: _kTextSecondary, fontSize: 11.5)),
              ],
            ),
          ),
          if (showMoreMenu && !member.isCaptain)
            GestureDetector(
              onTap: onMoreTap,
              child: const Icon(Icons.more_vert, color: _kTextSecondary, size: 18),
            ),
        ],
      ),
    );
  }
}