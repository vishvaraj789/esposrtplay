import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../routes/route_names.dart';
import '../provider/player_admin_provider.dart';
import '../widgets/player_list_tile.dart';

class AdminPlayersScreen extends ConsumerWidget {
  const AdminPlayersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playersAsync = ref.watch(filteredPlayersProvider);
    final filter = ref.watch(playerFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(backgroundColor: AppColors.backgroundDark, elevation: 0, title: const Text('Players')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by name, email or Free Fire UID',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onChanged: (v) => ref.read(playerSearchProvider.notifier).setQuery(v),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: PlayerFilter.values.map((f) {
                final selected = filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f.name[0].toUpperCase() + f.name.substring(1)),
                    selected: selected,
                    onSelected: (_) => ref.read(playerFilterProvider.notifier).setFilter(f),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.card,
                    labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontSize: 12.5),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: playersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.secondary)),
              error: (e, _) => Center(
                child: Text('Could not load players: $e', style: const TextStyle(color: Colors.redAccent)),
              ),
              data: (players) {
                if (players.isEmpty) {
                  return Center(child: Text('No players found', style: TextStyle(color: AppColors.textSecondary)));
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: players.length,
                  itemBuilder: (context, i) => PlayerListTile(
                    player: players[i],
                    onTap: () => context.push(Routes.adminPlayerDetailsPath(players[i].uid)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}