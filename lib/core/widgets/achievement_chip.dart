import 'package:flutter/material.dart';
import '../../models/achievement.dart';

class AchievementChip extends StatelessWidget {
  final Achievement achievement;

  const AchievementChip({
    super.key,
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: achievement.description,
      preferBelow: false,
      waitDuration: const Duration(milliseconds: 500),

      child: Chip(
        avatar: Icon(
          achievement.icon,
          color: achievement.unlocked
              ? achievement.color
              : Colors.grey,
          size: 20,
        ),

        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              achievement.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: achievement.unlocked
                    ? Colors.black
                    : Colors.grey,
              ),
            ),

            if (!achievement.unlocked) ...[
              const SizedBox(width: 5),
              const Icon(
                Icons.lock,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ],
        ),

        backgroundColor: achievement.unlocked
            ? achievement.color.withOpacity(0.15)
            : Colors.grey.shade300,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ),
      ),
    );
  }
}