import 'package:flutter/material.dart';

const _kGreen = Color(0xFF3DDC84);
const _kGold = Color(0xFFFFC24B);

/// Small pill badge, or bare icon variant for inline use next to a name.
class CaptainBadge extends StatelessWidget {
  final bool asPill;

  const CaptainBadge({super.key, this.asPill = true});

  @override
  Widget build(BuildContext context) {
    if (!asPill) {
      return const Icon(Icons.workspace_premium, color: _kGold, size: 14);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: _kGreen.withOpacity(0.16),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'CAPTAIN',
        style: TextStyle(color: _kGreen, fontSize: 9, fontWeight: FontWeight.w800),
      ),
    );
  }
}