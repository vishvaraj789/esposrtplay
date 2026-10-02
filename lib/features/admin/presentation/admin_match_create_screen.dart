import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_textfield.dart';
import '../../matches/provider/match_provider.dart';
import '../../tournaments/model/tournament_model.dart';
import '../../tournaments/provider/tournament_provider.dart';
import '../provider/tournament_admin_provider.dart';

class AdminMatchCreateScreen extends ConsumerStatefulWidget {
  const AdminMatchCreateScreen({super.key});
  @override
  ConsumerState<AdminMatchCreateScreen> createState() => _AdminMatchCreateScreenState();
}

class _AdminMatchCreateScreenState extends ConsumerState<AdminMatchCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _map = TextEditingController();
  final _round = TextEditingController(text: '1');
  String? _tournamentId;
  String? _teamAId;
  String? _teamBId;
  @override
  void dispose() { _map.dispose(); _round.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final tournaments = ref.watch(allTournamentsAdminProvider);
    final registrations = _tournamentId == null ? null : ref.watch(registrationsProvider(_tournamentId!));
    final submitting = ref.watch(createMatchControllerProvider).isSubmitting;
    final teams = registrations?.value ?? const <TeamRegistration>[];
    return Scaffold(backgroundColor: AppColors.backgroundDark, appBar: AppBar(backgroundColor: AppColors.backgroundDark, title: const Text('Create Match')), body: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(16), children: [
      tournaments.when(loading: () => const LinearProgressIndicator(), error: (error, _) => Text('Could not load tournaments: $error', style: const TextStyle(color: Colors.redAccent)), data: (items) => _dropdown<String>('Tournament', _tournamentId, items.map((item) => DropdownMenuItem(value: item.id, child: Text(item.name))).toList(), (value) => setState(() { _tournamentId = value; _teamAId = null; _teamBId = null; }))),
      const SizedBox(height: 14),
      if (_tournamentId != null && registrations!.isLoading) const LinearProgressIndicator(),
      if (_tournamentId != null) ...[
        _dropdown<String>('Team A', _teamAId, teams.map((item) => DropdownMenuItem(value: item.teamId, child: Text(item.teamName))).toList(), (value) => setState(() { _teamAId = value; if (_teamBId == value) _teamBId = null; })), const SizedBox(height: 14),
        _dropdown<String>('Team B', _teamBId, teams.where((item) => item.teamId != _teamAId).map((item) => DropdownMenuItem(value: item.teamId, child: Text(item.teamName))).toList(), (value) => setState(() => _teamBId = value)), const SizedBox(height: 14),
      ],
      AppTextField(controller: _round, label: 'Round', keyboardType: TextInputType.number, validator: (value) => int.tryParse(value ?? '') == null ? 'Enter a round number' : null), const SizedBox(height: 14),
      AppTextField(controller: _map, label: 'Map', hint: 'Bermuda', validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null), const SizedBox(height: 24),
      AppButton(text: 'Create match', icon: Icons.add, isLoading: submitting, onPressed: submitting ? null : () => _submit(teams)),
    ])));
  }
  Widget _dropdown<T>(String label, T? value, List<DropdownMenuItem<T>> items, ValueChanged<T?> onChanged) => DropdownButtonFormField<T>(value: value, items: items, onChanged: onChanged, validator: (value) => value == null ? 'Required' : null, dropdownColor: AppColors.surfaceDark, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.white70), filled: true, fillColor: AppColors.surfaceDark, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)));
  Future<void> _submit(List<TeamRegistration> teams) async {
    if (!_formKey.currentState!.validate() || _tournamentId == null || _teamAId == null || _teamBId == null || _teamAId == _teamBId) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choose a tournament and two different teams'))); return; }
    final a = teams.firstWhere((team) => team.teamId == _teamAId); final b = teams.firstWhere((team) => team.teamId == _teamBId);
    await ref.read(createMatchControllerProvider.notifier).submit(tournamentId: _tournamentId!, round: int.parse(_round.text), teamAId: a.teamId, teamAName: a.teamName, teamBId: b.teamId, teamBName: b.teamName, map: _map.text.trim(), scheduledAt: DateTime.now().add(const Duration(hours: 1)));
    final state = ref.read(createMatchControllerProvider); if (mounted && state.error == null) Navigator.pop(context); if (mounted && state.error != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
  }
}
