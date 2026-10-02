import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../routes/route_names.dart';
import '../../matches/models/match_model.dart';
import '../../matches/provider/match_provider.dart';
import '../../matches/widgets/match_card.dart';

class AdminMatchesScreen extends ConsumerStatefulWidget {
  const AdminMatchesScreen({super.key});
  @override
  ConsumerState<AdminMatchesScreen> createState() => _AdminMatchesScreenState();
}

class _AdminMatchesScreenState extends ConsumerState<AdminMatchesScreen> {
  MatchStatus? _filter;
  @override
  Widget build(BuildContext context) {
    final matches = ref.watch(allMatchesProvider);
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(backgroundColor: AppColors.backgroundDark, title: const Text('Manage Matches')),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => context.push(Routes.adminMatchCreate), icon: const Icon(Icons.add), label: const Text('Create')),
      body: Column(children: [
        SizedBox(height: 54, child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), children: [
          _filterChip('All', null), ...MatchStatus.values.map((status) => _filterChip(status.name, status)),
        ])),
        Expanded(child: matches.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Could not load matches: $error', style: const TextStyle(color: Colors.redAccent))),
          data: (items) { final visible = _filter == null ? items : items.where((item) => item.status == _filter).toList(); return visible.isEmpty ? const Center(child: Text('No matches found', style: TextStyle(color: Colors.white60))) : ListView.separated(padding: const EdgeInsets.fromLTRB(16, 4, 16, 90), itemCount: visible.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (_, index) => MatchCard(match: visible[index], onTap: () => context.push(Routes.adminMatchManagePath(visible[index].id)))); },
        )),
      ]),
    );
  }
  Widget _filterChip(String label, MatchStatus? status) { final active = status == _filter; return Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(label), selected: active, onSelected: (_) => setState(() => _filter = status))); }
}
