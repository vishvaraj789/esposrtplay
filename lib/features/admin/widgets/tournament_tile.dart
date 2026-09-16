import 'package:flutter/material.dart';

import '../../tournaments/model/tournament_model.dart';

const _kCard = Color(0xFF171821);
const _kHairline = Color(0xFF2A2C38);
const _kTextSecondary = Color(0xFF9CA0AF);
const _kGold = Color(0xFFFFC24B);

class TournamentTile extends StatelessWidget {
  final Tournament tournament;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const TournamentTile({
    super.key,
    required this.tournament,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: _kHairline)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(color: _statusColor, shape: BoxShape.circle),
        ),
        title: Text(tournament.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        subtitle: Text(
          '${tournament.currentParticipants}/${tournament.maxParticipants} teams · ₹${tournament.prizePool.toStringAsFixed(0)}',
          style: const TextStyle(color: _kTextSecondary, fontSize: 11.5),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(icon: const Icon(Icons.edit, color: _kGold, size: 18), onPressed: onEdit),
            if (onDelete != null)
              IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}