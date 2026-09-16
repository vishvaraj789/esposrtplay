import 'package:flutter/material.dart';

import '../models/match_model.dart';

const _kCard = Color(0xFF171821);
const _kHairline = Color(0xFF2A2C38);
const _kGreen = Color(0xFF3DDC84);

/// Admin dialog to pick the winning team. Returns (winnerId, winnerName)
/// via Navigator.pop, or null if cancelled.
class WinnerDialog extends StatelessWidget {
  final MatchModel match;

  const WinnerDialog({super.key, required this.match});

  static Future<(String, String)?> show(BuildContext context, MatchModel match) {
    return showDialog<(String, String)?>(
      context: context,
      builder: (_) => WinnerDialog(match: match),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _kCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Declare Winner', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _teamOption(context, match.teamAId, match.teamAName),
          const SizedBox(height: 10),
          _teamOption(context, match.teamBId, match.teamBName),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }

  Widget _teamOption(BuildContext context, String teamId, String teamName) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _kHairline),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => Navigator.pop(context, (teamId, teamName)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, color: _kGreen, size: 18),
            const SizedBox(width: 8),
            Text(teamName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}