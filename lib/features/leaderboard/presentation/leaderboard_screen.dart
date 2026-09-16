import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/leaderboard_provider.dart';
import '../widgets/top_three_card.dart';
import '../widgets/leaderboard_tile.dart';

const _kBg = Color(0xFF0F172A);
const _kTextSecondary = Color(0xFF9CA0AF);

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  @override
  Widget build(BuildContext context) {
    final tournamentsAsync = ref.watch(leaderboardEligibleTournamentsProvider);
    final selectedId = ref.watch(selectedLeaderboardTournamentProvider);

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(title: const Text('Leaderboard'), backgroundColor: _kBg, elevation: 0),
      body: tournamentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e', style: const TextStyle(color: Colors.white))),
        data: (tournaments) {
          if (tournaments.isEmpty) {
            return const Center(
              child: Text('No tournaments to show a leaderboard for yet', style: TextStyle(color: _kTextSecondary)),
            );
          }

          // Default to the first tournament once loaded.
          final effectiveId = selectedId ?? tournaments.first.id;
          if (selectedId == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(selectedLeaderboardTournamentProvider.notifier).state = effectiveId;
            });
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<String>(
                  initialValue: effectiveId,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  dropdownColor: const Color(0xFF1E293B),
                  style: const TextStyle(color: Colors.white),
                  items: tournaments
                      .map((t) => DropdownMenuItem(value: t.id, child: Text(t.name, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (id) => ref.read(selectedLeaderboardTournamentProvider.notifier).state = id,
                ),
              ),
              Expanded(
                child: Consumer(
                  builder: (context, ref, _) {
                    final leaderboardAsync = ref.watch(leaderboardProvider(effectiveId));
                    return leaderboardAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
                      data: (entries) {
                        if (entries.isEmpty) {
                          return const Center(
                            child: Text('No results yet for this tournament', style: TextStyle(color: _kTextSecondary)),
                          );
                        }
                        final rest = entries.where((e) => e.rank > 3).toList();
                        return ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          children: [
                            TopThreeCard(entries: entries),
                            const SizedBox(height: 16),
                            ...rest.map((e) => LeaderboardTile(entry: e)),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}