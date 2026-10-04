import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/provider/auth_provider.dart';
import '../model/tournament_model.dart';
import '../provider/tournament_provider.dart';

class CreateTournamentScreen extends ConsumerStatefulWidget {
  const CreateTournamentScreen({super.key});

  @override
  ConsumerState<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends ConsumerState<CreateTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mapController = TextEditingController();
  final _maxParticipantsController = TextEditingController(text: '16');
  final _entryFeeController = TextEditingController(text: '0');
  final _firstPrizeController = TextEditingController();
  final _secondPrizeController = TextEditingController();
  final _thirdPrizeController = TextEditingController();

  TournamentMode _mode = TournamentMode.squad;
  DateTime _startTime = DateTime.now().add(const Duration(days: 1));

  String _modeLabel(TournamentMode mode) {
    switch (mode) {
      case TournamentMode.solo:
        return 'SOLO';
      case TournamentMode.duo:
        return 'DUO';
      case TournamentMode.squad:
        return 'SQUAD';
      case TournamentMode.clashSquad:
        return 'CLASH SQUAD';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mapController.dispose();
    _maxParticipantsController.dispose();
    _entryFeeController.dispose();
    _firstPrizeController.dispose();
    _secondPrizeController.dispose();
    _thirdPrizeController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_startTime));
    if (time == null) return;

    setState(() {
      _startTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;

    final first = num.tryParse(_firstPrizeController.text.trim()) ?? 0;
    final second = num.tryParse(_secondPrizeController.text.trim()) ?? 0;
    final third = num.tryParse(_thirdPrizeController.text.trim()) ?? 0;
    final prizePool = (first + second + third).toDouble();

    final draft = Tournament(
      id: '',
      name: _nameController.text.trim(),
      status: TournamentStatus.upcoming,
      mode: _mode,
      map: _mapController.text.trim(),
      startTime: _startTime,
      maxParticipants: int.tryParse(_maxParticipantsController.text.trim()) ?? 16,
      currentParticipants: 0,
      entryFee: double.tryParse(_entryFeeController.text.trim()) ?? 0,
      prizePool: prizePool,
      prizeBreakdown: {
        if (first > 0) '1st': first.toDouble(),
        if (second > 0) '2nd': second.toDouble(),
        if (third > 0) '3rd': third.toDouble(),
      },
      createdBy: uid,
      createdAt: DateTime.now(),
    );

    await ref.read(createTournamentControllerProvider.notifier).submit(draft);

    if (!mounted) return;

    final state = ref.read(createTournamentControllerProvider);
    if (state.createdId != null) {
      Navigator.pop(context);
    } else if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${state.error}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createTournamentControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        title: const Text('Create Tournament'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field(controller: _nameController, label: 'Tournament Name', validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
            const SizedBox(height: 14),
            DropdownButtonFormField<TournamentMode>(
              initialValue: _mode,
              dropdownColor: AppColors.card,
              style: const TextStyle(color: Colors.white),
              decoration: _decoration('Mode'),
              items: TournamentMode.values   // fixed: was "iitems"
                  .map((m) => DropdownMenuItem(value: m, child: Text(_modeLabel(m))))
                  .toList(),
              onChanged: (v) => setState(() => _mode = v ?? _mode),
            ),
            const SizedBox(height: 14),
            _field(controller: _mapController, label: 'Map', validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
            const SizedBox(height: 14),
            InkWell(
              onTap: _pickDateTime,
              child: InputDecorator(
                decoration: _decoration('Start Date & Time'),
                child: Text(
                  '${_startTime.day}/${_startTime.month}/${_startTime.year} • ${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _field(
                    controller: _maxParticipantsController,
                    label: 'Max Teams',
                    keyboardType: TextInputType.number,
                    validator: (v) => int.tryParse(v ?? '') == null ? 'Enter a number' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(
                    controller: _entryFeeController,
                    label: 'Entry Fee (₹)',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Prize Breakdown', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            _field(controller: _firstPrizeController, label: '1st Place (₹)', keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            _field(controller: _secondPrizeController, label: '2nd Place (₹)', keyboardType: TextInputType.number),
            const SizedBox(height: 10),
            _field(controller: _thirdPrizeController, label: '3rd Place (₹)', keyboardType: TextInputType.number),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: createState.isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: createState.isSubmitting
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Create Tournament', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: _decoration(label),
      validator: validator,
    );
  }
}