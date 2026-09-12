import 'package:flutter/material.dart';

import '../provider/profile_provider.dart';

const _kCard = Color(0xFF171821);
const _kHairline = Color(0xFF2A2C38);
const _kGold = Color(0xFFFFC24B);
const _kTextSecondary = Color(0xFF9CA0AF);

const Map<String, IconData> _iconMap = {
  'emoji_events': Icons.emoji_events,
  'military_tech': Icons.military_tech,
  'workspace_premium': Icons.workspace_premium,
  'local_fire_department': Icons.local_fire_department,
  'groups': Icons.groups,
  'shield': Icons.shield,
};

class AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const AchievementCard({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    final icon = _iconMap[achievement.iconName] ?? Icons.emoji_events;

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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: (achievement.unlocked ? _kGold : _kTextSecondary).withOpacity(0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: achievement.unlocked ? _kGold : _kTextSecondary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    color: achievement.unlocked ? Colors.white : _kTextSecondary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(achievement.description, style: const TextStyle(color: _kTextSecondary, fontSize: 11.5)),
              ],
            ),
          ),
          if (!achievement.unlocked) const Icon(Icons.lock_outline, color: _kTextSecondary, size: 16),
        ],
      ),
    );
  }
}