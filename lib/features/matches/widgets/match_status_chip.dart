import 'package:flutter/material.dart';

import '../models/match_model.dart';

class MatchStatusChip extends StatelessWidget {
  final MatchStatus status;

  const MatchStatusChip({super.key, required this.status});

  Color get _color {
    switch (status) {
      case MatchStatus.upcoming:
        return const Color(0xFFFF6A3D);
      case MatchStatus.live:
        return const Color(0xFFE23744);
      case MatchStatus.completed:
        return const Color(0xFF3DDC84);
      case MatchStatus.cancelled:
        return const Color(0xFF9CA0AF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLive = status == MatchStatus.live;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: _color, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLive) ...[
            Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
            const SizedBox(width: 4),
          ],
          Text(
            status.name.toUpperCase(),
            style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}