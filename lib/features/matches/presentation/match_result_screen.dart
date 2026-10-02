import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../provider/match_provider.dart';

class MatchResultScreen extends ConsumerWidget {
  final String matchId;
  const MatchResultScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final match = ref.watch(matchDetailProvider(matchId));
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(backgroundColor: AppColors.backgroundDark, title: const Text('Match Result')),
      body: match.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Could not load result: $error', style: const TextStyle(color: Colors.redAccent))),
        data: (item) => item == null
            ? const Center(child: Text('Match not found', style: TextStyle(color: Colors.white70)))
            : Center(child: Padding(padding: const EdgeInsets.all(24), child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(color: const Color(0xFF171821), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFFFC24B))),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.emoji_events, size: 58, color: Color(0xFFFFC24B)),
                  const SizedBox(height: 16),
                  Text(item.hasWinner ? 'Winner' : 'Result pending', style: const TextStyle(color: Colors.white54)),
                  const SizedBox(height: 6),
                  Text(item.winnerName ?? 'The result will be posted soon', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 22),
                  Text('${item.teamAName}  vs  ${item.teamBName}', style: const TextStyle(color: Colors.white60)),
                ]),
              ))),
      ),
    );
  }
}
