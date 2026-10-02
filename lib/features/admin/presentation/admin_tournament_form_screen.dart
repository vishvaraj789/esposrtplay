import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_textfield.dart';
import '../../tournaments/model/tournament_model.dart';
import '../../tournaments/provider/tournament_provider.dart';
import '../provider/tournament_admin_provider.dart';

class AdminTournamentFormScreen extends ConsumerStatefulWidget {
  final String tournamentId;
  const AdminTournamentFormScreen({super.key, required this.tournamentId});
  @override
  ConsumerState<AdminTournamentFormScreen> createState() => _AdminTournamentFormScreenState();
}

class _AdminTournamentFormScreenState extends ConsumerState<AdminTournamentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _map = TextEditingController();
  final _maxTeams = TextEditingController(text: '16');
  final _entryFee = TextEditingController(text: '0');
  final _prizePool = TextEditingController(text: '0');
  TournamentMode _mode = TournamentMode.squad;
  TournamentStatus _status = TournamentStatus.upcoming;
  var _initialised = false;
  bool get _isNew => widget.tournamentId == 'new';

  @override
  void dispose() { _name.dispose(); _map.dispose(); _maxTeams.dispose(); _entryFee.dispose(); _prizePool.dispose(); super.dispose(); }

  void _populate(Tournament tournament) {
    if (_initialised) return;
    _initialised = true; _name.text = tournament.name; _map.text = tournament.map; _maxTeams.text = tournament.maxParticipants.toString(); _entryFee.text = tournament.entryFee.toString(); _prizePool.text = tournament.prizePool.toString(); _mode = tournament.mode; _status = tournament.status;
  }

  @override
  Widget build(BuildContext context) {
    final existing = _isNew ? null : ref.watch(tournamentDetailProvider(widget.tournamentId));
    final existingTournament = existing?.value;
    if (existingTournament != null) _populate(existingTournament);
    final busy = _isNew
        ? ref.watch(createTournamentControllerProvider).isSubmitting
        : ref.watch(tournamentAdminActionsControllerProvider).isLoading;
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(backgroundColor: AppColors.backgroundDark, title: Text(_isNew ? 'Create Tournament' : 'Edit Tournament')),
      body: !_isNew && existing!.isLoading ? const Center(child: CircularProgressIndicator()) : Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          if (existing?.hasError == true) Text('Could not load tournament: ${existing?.error}', style: const TextStyle(color: Colors.redAccent)),
          AppTextField(controller: _name, label: 'Tournament name', validator: _required), const SizedBox(height: 14),
          AppTextField(controller: _map, label: 'Map', hint: 'Bermuda', validator: _required), const SizedBox(height: 14),
          _select<TournamentMode>('Mode', _mode, TournamentMode.values, (value) => setState(() => _mode = value)), const SizedBox(height: 14),
          _select<TournamentStatus>('Status', _status, TournamentStatus.values, (value) => setState(() => _status = value)), const SizedBox(height: 14),
          AppTextField(controller: _maxTeams, label: 'Maximum teams', keyboardType: TextInputType.number, validator: _positiveInt), const SizedBox(height: 14),
          AppTextField(controller: _entryFee, label: 'Entry fee (₹)', keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: _number), const SizedBox(height: 14),
          AppTextField(controller: _prizePool, label: 'Prize pool (₹)', keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: _number), const SizedBox(height: 24),
          AppButton(text: _isNew ? 'Create tournament' : 'Save changes', icon: Icons.save_outlined, isLoading: busy, onPressed: busy ? null : _submit),
        ]),
      ),
    );
  }

  Widget _select<T>(String label, T value, List<T> values, ValueChanged<T> onChanged) => DropdownButtonFormField<T>(
    value: value, dropdownColor: AppColors.surfaceDark, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.white70), filled: true, fillColor: AppColors.surfaceDark, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)), items: values.map((item) => DropdownMenuItem(value: item, child: Text(item.toString().split('.').last))).toList(), onChanged: (item) { if (item != null) onChanged(item); },
  );
  String? _required(String? value) => value == null || value.trim().isEmpty ? 'Required' : null;
  String? _positiveInt(String? value) => int.tryParse(value ?? '') == null || int.parse(value!) < 2 ? 'Enter at least 2' : null;
  String? _number(String? value) => double.tryParse(value ?? '') == null ? 'Enter a number' : null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final maxTeams = int.parse(_maxTeams.text); final entryFee = double.parse(_entryFee.text); final prizePool = double.parse(_prizePool.text);
    if (_isNew) {
      await ref.read(createTournamentControllerProvider.notifier).submit(Tournament(id: '', name: _name.text.trim(), status: _status, mode: _mode, map: _map.text.trim(), startTime: DateTime.now().add(const Duration(days: 1)), maxParticipants: maxTeams, currentParticipants: 0, entryFee: entryFee, prizePool: prizePool, prizeBreakdown: const {}, createdBy: FirebaseAuth.instance.currentUser?.uid ?? '', createdAt: DateTime.now()));
      final state = ref.read(createTournamentControllerProvider);
      if (mounted && state.error == null) Navigator.pop(context);
      if (mounted && state.error != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
    } else {
      final ok = await ref.read(tournamentAdminActionsControllerProvider.notifier).update(widget.tournamentId, {'name': _name.text.trim(), 'map': _map.text.trim(), 'mode': _mode.name, 'status': _status.name, 'maxParticipants': maxTeams, 'entryFee': entryFee, 'prizePool': prizePool, 'updatedAt': Timestamp.now()});
      if (mounted && ok) Navigator.pop(context);
      if (mounted && !ok) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not save changes')));
    }
  }
}
