import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/player_admin_model.dart';

class PlayerListTile extends StatelessWidget {
  final AdminPlayer player;
  final VoidCallback? onTap;

  const PlayerListTile({super.key, required this.player, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSuspended = player.status == PlayerStatus.suspended;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSuspended ? AppColors.danger.withValues(alpha: 0.5) : AppColors.hairline),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.hairline,
          backgroundImage: player.photoUrl != null ? NetworkImage(player.photoUrl!) : null,
          child: player.photoUrl == null
              ? Text(player.nickname.isNotEmpty ? player.nickname[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white))
              : null,
        ),
        title: Row(
          children: [
            Flexible(child: Text(player.nickname, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
            if (player.verified) ...[
              const SizedBox(width: 4),
              const Icon(Icons.verified, color: AppColors.secondary, size: 15),
            ],
          ],
        ),
        subtitle: Text(player.email, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        trailing: isSuspended
            ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
          child: const Text('SUSPENDED', style: TextStyle(color: AppColors.danger, fontSize: 9.5, fontWeight: FontWeight.w800)),
        )
            : const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      ),
    );
  }
}