import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../routes/route_names.dart';
import '../models/match_model.dart';
import '../provider/match_provider.dart';
import '../widgets/match_status_chip.dart';

class MatchDetailsScreen extends ConsumerWidget {
  final String matchId;
  const MatchDetailsScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final match = ref.watch(matchDetailProvider(matchId));
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(backgroundColor: AppColors.backgroundDark, title: const Text('Match Details')),
      body: match.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Could not load match: $error', style: const TextStyle(color: Colors.redAccent))),
        data: (item) {
          if (item == null) return const Center(child: Text('Match not found', style: TextStyle(color: Colors.white70)));
          return ListView(padding: const EdgeInsets.all(16), children: [
            _MatchHero(match: item),
            const SizedBox(height: 16),
            _InfoCard(match: item),
            const SizedBox(height: 20),
            if (item.status == MatchStatus.live || item.hasRoomInfo)
              FilledButton.icon(
                onPressed: () => context.push(Routes.matchRoomPath(item.id)),
                icon: const Icon(Icons.meeting_room_outlined),
                label: const Text('View Room Details'),
              ),
            if (item.isCompleted)
              OutlinedButton.icon(
                onPressed: () => context.push(Routes.matchResultPath(item.id)),
                icon: const Icon(Icons.emoji_events_outlined),
                label: const Text('View Result'),
              ),
          ]);
        },
      ),
    );
  }
}

class _MatchHero extends StatelessWidget {
  final MatchModel match;
  const _MatchHero({required this.match});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFF171821), borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('ROUND ${match.round}', style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.w700)), MatchStatusChip(status: match.status)]),
          const SizedBox(height: 28),
          Row(children: [
            Expanded(child: Text(match.teamAName, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800))),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 14), child: Text('VS', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w800))),
            Expanded(child: Text(match.teamBName, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800))),
          ]),
        ]),
      );
}

class _InfoCard extends StatelessWidget {
  final MatchModel match;
  const _InfoCard({required this.match});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF171821), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF2A2C38))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Match information', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          _row(Icons.map_outlined, 'Map', match.map.isEmpty ? 'To be announced' : match.map),
          const SizedBox(height: 12),
          _row(Icons.calendar_today_outlined, 'Scheduled', '${match.scheduledAt.day}/${match.scheduledAt.month}/${match.scheduledAt.year} · ${TimeOfDay.fromDateTime(match.scheduledAt).format(context)}'),
        ]),
      );
  Widget _row(IconData icon, String label, String value) => Row(children: [Icon(icon, size: 18, color: Colors.white54), const SizedBox(width: 10), Text('$label  ', style: const TextStyle(color: Colors.white54)), Expanded(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(color: Colors.white))) ]);
}
