import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../provider/match_provider.dart';
import '../widgets/room_info_card.dart';

class MatchRoomScreen extends ConsumerWidget {
  final String matchId;
  const MatchRoomScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final match = ref.watch(matchDetailProvider(matchId));
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(backgroundColor: AppColors.backgroundDark, title: const Text('Match Room')),
      body: match.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Could not load room: $error', style: const TextStyle(color: Colors.redAccent))),
        data: (item) => item == null ? const Center(child: Text('Match not found', style: TextStyle(color: Colors.white70))) : ListView(padding: const EdgeInsets.all(16), children: [
          Text('${item.teamAName} vs ${item.teamBName}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(item.map.isEmpty ? 'Map to be announced' : item.map, style: const TextStyle(color: Colors.white54)),
          const SizedBox(height: 20),
          RoomInfoCard(roomId: item.roomId, roomPassword: item.roomPassword),
          const SizedBox(height: 16),
          const Text('Use the copy buttons to share room details safely with your team.', style: TextStyle(color: Colors.white54, fontSize: 12)),
        ]),
      ),
    );
  }
}
