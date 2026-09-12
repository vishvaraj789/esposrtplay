import 'package:flutter/material.dart';

/// Placeholder shown for empty lists (no tournaments, no teams, etc).
class EmptyWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  final Widget? action;

  const EmptyWidget({
    super.key,
    this.message = 'Nothing here yet',
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey[500]),
            ),
            if (action != null) ...[
              const SizedBox(height: 16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}