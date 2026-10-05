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

  /// Publish / move back to draft. Shown only when provided.
  final VoidCallback? onTogglePublish;

  const TournamentTile({
    super.key,
    required this.tournament,
    this.onEdit,
    this.onDelete,
    this.onTap,
    this.onTogglePublish,
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
    final published = tournament.isPublished;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: _kHairline)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.only(left: 14, right: 4, top: 4, bottom: 4),
        leading: Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(color: _statusColor, shape: BoxShape.circle),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                tournament.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (published ? const Color(0xFF3DDC84) : _kGold).withOpacity(0.16),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                published ? 'PUBLISHED' : 'DRAFT',
                style: TextStyle(
                  color: published ? const Color(0xFF3DDC84) : _kGold,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          '${tournament.currentParticipants}/${tournament.maxParticipants} teams · ₹${tournament.prizePool.toStringAsFixed(0)} · ${tournament.mode.name}',
          style: const TextStyle(color: _kTextSecondary, fontSize: 11.5),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onTogglePublish != null)
              IconButton(
                tooltip: published ? 'Move to draft' : 'Publish',
                icon: Icon(published ? Icons.visibility_off_outlined : Icons.publish, color: const Color(0xFF3DA9FC), size: 18),
                onPressed: onTogglePublish,
              ),
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