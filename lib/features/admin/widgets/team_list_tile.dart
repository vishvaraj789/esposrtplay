import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/team_admin_model.dart';

class TeamListTile extends StatelessWidget {
  final AdminTeam team;
  final VoidCallback? onTap;

  const TeamListTile({super.key, required this.team, this.onTap});

  @override
  Widget build(BuildContext context) {
    final suspended = team.isSuspended;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: suspended ? AppColors.danger.withValues(alpha: 0.5) : AppColors.hairline),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.hairline,
          backgroundImage: team.logoUrl != null && team.logoUrl!.isNotEmpty ? NetworkImage(team.logoUrl!) : null,
          child: team.logoUrl == null || team.logoUrl!.isEmpty
              ? const Icon(Icons.shield, color: Colors.white54, size: 18)
              : null,
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                team.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
            if (team.verified) ...[
              const SizedBox(width: 4),
              const Icon(Icons.verified, color: AppColors.secondary, size: 15),
            ],
          ],
        ),
        subtitle: Text(
          '[${team.tag}] · ${team.memberUids.length}/${team.maxMembers} members',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        trailing: suspended
            ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'SUSPENDED',
            style: TextStyle(color: AppColors.danger, fontSize: 9.5, fontWeight: FontWeight.w800),
          ),
        )
            : Icon(Icons.chevron_right, color: AppColors.textSecondary),
      ),
    );
  }
}