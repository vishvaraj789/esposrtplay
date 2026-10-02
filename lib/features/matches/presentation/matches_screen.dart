import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../routes/route_names.dart';
import '../models/match_model.dart';
import '../provider/match_provider.dart';
import '../widgets/match_card.dart';

class MatchesScreen extends ConsumerStatefulWidget {
  const MatchesScreen({super.key});

  @override
  ConsumerState<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends ConsumerState<MatchesScreen> {
  var _showLive = true;

  @override
  Widget build(BuildContext context) {
    final matches = ref.watch(_showLive ? liveMatchesProvider : upcomingMatchesProvider);
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(backgroundColor: AppColors.backgroundDark, title: const Text('Matches')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Live'), icon: Icon(Icons.sensors)),
              ButtonSegment(value: false, label: Text('Upcoming'), icon: Icon(Icons.schedule)),
            ],
            selected: {_showLive},
            onSelectionChanged: (value) => setState(() => _showLive = value.first),
          ),
        ),
        Expanded(
          child: matches.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _Message(icon: Icons.error_outline, text: 'Could not load matches\n$error'),
            data: (items) => items.isEmpty
                ? _Message(icon: Icons.sports_esports_outlined, text: _showLive ? 'No live matches right now' : 'No upcoming matches')
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, index) => MatchCard(
                      match: items[index],
                      onTap: () => context.push(Routes.matchDetailsPath(items[index].id)),
                    ),
                  ),
          ),
        ),
      ]),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Message({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 42, color: Colors.white38),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60)),
          ]),
        ),
      );
}
