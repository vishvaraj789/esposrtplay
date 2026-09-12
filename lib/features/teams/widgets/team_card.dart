import 'package:flutter/material.dart';

import '../repository/team_repository.dart';
import 'captain_badge.dart';

const _kCard = Color(0xFF171821);
const _kPurple = Color(0xFF8B5CF6);
const _kTextPrimary = Colors.white;
const _kTextSecondary = Color(0xFF9CA0AF);
const _kBrandGradient = LinearGradient(
  colors: [Color(0xFFFF6A3D), Color(0xFFFF3D5A)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

class TeamCard extends StatelessWidget {
  final TeamModel team;
  final bool isViewerCaptain;
  final VoidCallback? onTap;

  const TeamCard({super.key, required this.team, this.isViewerCaptain = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kPurple.withOpacity(0.45)),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(gradient: _kBrandGradient, borderRadius: BorderRadius.circular(14)),
              child: team.logoUrl != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(team.logoUrl!, fit: BoxFit.cover),
              )
                  : const Icon(Icons.shield, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(team.name,
                          style: const TextStyle(color: _kTextPrimary, fontSize: 17, fontWeight: FontWeight.w800)),
                      if (isViewerCaptain) ...[
                        const SizedBox(width: 6),
                        const CaptainBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${team.memberUids.length} / ${team.maxMembers} members · Tag: ${team.tag}',
                      style: const TextStyle(color: _kTextSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: _kTextSecondary),
          ],
        ),
      ),
    );
  }
}