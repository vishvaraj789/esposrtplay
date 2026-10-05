import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_textfield.dart';
import '../../tournaments/model/tournament_model.dart';
import '../../tournaments/provider/tournament_provider.dart';
import '../provider/tournament_admin_provider.dart';

const _kGame = 'Free Fire MAX';
const _kMatchTypes = ['Battle Royale', 'Clash Squad', 'Lone Wolf', 'Custom Room'];
const _kMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

class AdminTournamentFormScreen extends ConsumerStatefulWidget {
  final String tournamentId;
  const AdminTournamentFormScreen({super.key, required this.tournamentId});

  @override
  ConsumerState<AdminTournamentFormScreen> createState() => _AdminTournamentFormScreenState();
}

class _AdminTournamentFormScreenState extends ConsumerState<AdminTournamentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _map = TextEditingController();
  final _maxTeams = TextEditingController(text: '16');
  final _entryFee = TextEditingController(text: '0');
  final _prizePool = TextEditingController(text: '0');
  final _rules = TextEditingController();
  final _game = TextEditingController(text: _kGame);

  TournamentMode _mode = TournamentMode.squad;
  String _matchType = _kMatchTypes.first;
  TournamentStatus _stage = TournamentStatus.upcoming;
  bool _published = false; // new tournaments start as drafts
  DateTime? _regStart;
  DateTime? _regEnd;
  DateTime? _date;

  String? _existingBannerUrl;
  File? _newBanner;
  bool _removeBanner = false;
  int _currentParticipants = 0;

  var _initialised = false;
  bool get _isNew => widget.tournamentId == 'new';

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _map.dispose();
    _maxTeams.dispose();
    _entryFee.dispose();
    _prizePool.dispose();
    _rules.dispose();
    _game.dispose();
    super.dispose();
  }

  void _populate(Tournament t) {
    if (_initialised) return;
    _initialised = true;
    _name.text = t.name;
    _description.text = t.description;
    _map.text = t.map;
    _maxTeams.text = t.maxParticipants.toString();
    _entryFee.text = t.entryFee.toString();
    _prizePool.text = t.prizePool.toString();
    _rules.text = t.rules;
    _mode = t.mode;
    _matchType = _kMatchTypes.contains(t.matchType) ? t.matchType : _kMatchTypes.first;
    _stage = t.status;
    _published = t.isPublished;
    _regStart = t.registrationStart;
    _regEnd = t.registrationEnd;
    _date = t.startTime;
    _existingBannerUrl = t.bannerUrl;
    _currentParticipants = t.currentParticipants;
  }

  // ---------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final existing = _isNew ? null : ref.watch(tournamentDetailProvider(widget.tournamentId));
    final existingTournament = existing?.value;
    if (existingTournament != null) _populate(existingTournament);

    final busy = ref.watch(tournamentAdminActionsControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: Text(_isNew ? 'Create Tournament' : 'Edit Tournament'),
      ),
      body: !_isNew && existing!.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (existing?.hasError == true)
              Text('Could not load tournament: ${existing?.error}', style: const TextStyle(color: Colors.redAccent)),

            _sectionTitle('Basics'),
            AppTextField(controller: _name, label: 'Tournament name', validator: _required),
            const SizedBox(height: 14),
            AppTextField(
              controller: _description,
              label: 'Description',
              hint: 'What is this tournament about?',
              maxLines: 3,
              validator: _required,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _game,
              label: 'Game',
              enabled: false,
            ),

            _sectionTitle('Format'),
            _select<TournamentMode>(
              'Mode',
              _mode,
              TournamentMode.values.where((m) => m != TournamentMode.clashSquad || _mode == TournamentMode.clashSquad).toList(),
                  (m) => setState(() => _mode = m),
              labelOf: (m) => m == TournamentMode.clashSquad ? 'Clash Squad' : m.name[0].toUpperCase() + m.name.substring(1),
            ),
            const SizedBox(height: 14),
            _select<String>('Match type', _matchType, _kMatchTypes, (v) => setState(() => _matchType = v)),
            const SizedBox(height: 14),
            AppTextField(controller: _map, label: 'Map', hint: 'Bermuda', validator: _required),

            _sectionTitle('Money & slots'),
            AppTextField(
              controller: _entryFee,
              label: 'Entry fee (₹)',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _nonNegativeNumber,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _prizePool,
              label: 'Prize pool (₹)',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: _nonNegativeNumber,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _maxTeams,
              label: _mode == TournamentMode.solo ? 'Maximum players' : 'Maximum teams',
              keyboardType: TextInputType.number,
              validator: _maxSlots,
            ),

            _sectionTitle('Schedule'),
            _dateField(
              label: 'Registration start',
              value: _regStart,
              onPicked: (d) => setState(() => _regStart = d),
              validator: () => _regStart == null ? 'Pick a date' : null,
            ),
            const SizedBox(height: 14),
            _dateField(
              label: 'Registration end',
              value: _regEnd,
              onPicked: (d) => setState(() => _regEnd = d),
              validator: () {
                if (_regEnd == null) return 'Pick a date';
                if (_regStart != null && !_regEnd!.isAfter(_regStart!)) return 'Must be after registration start';
                return null;
              },
            ),
            const SizedBox(height: 14),
            _dateField(
              label: 'Tournament date',
              value: _date,
              onPicked: (d) => setState(() => _date = d),
              validator: () {
                if (_date == null) return 'Pick a date';
                if (_regEnd != null && _date!.isBefore(_regEnd!)) return 'Must be after registration end';
                return null;
              },
            ),

            _sectionTitle('Rules'),
            AppTextField(
              controller: _rules,
              label: 'Rules',
              hint: 'One rule per line',
              maxLines: 6,
            ),

            _sectionTitle('Banner image'),
            _bannerPicker(),

            _sectionTitle('Publishing'),
            Container(
              decoration: BoxDecoration(color: AppColors.surfaceDark, borderRadius: BorderRadius.circular(14)),
              child: SwitchListTile(
                value: _published,
                onChanged: (v) => setState(() => _published = v),
                title: Text(_published ? 'Published' : 'Draft', style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                  _published ? 'Visible to players' : 'Only admins can see it',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
            ),
            if (!_isNew) ...[
              const SizedBox(height: 14),
              _select<TournamentStatus>(
                'Tournament stage',
                _stage,
                TournamentStatus.values,
                    (v) => setState(() => _stage = v),
                labelOf: (s) => s.name[0].toUpperCase() + s.name.substring(1),
              ),
            ],

            const SizedBox(height: 28),
            AppButton(
              text: _isNew ? 'Create tournament' : 'Save changes',
              icon: Icons.save_outlined,
              isLoading: busy,
              onPressed: busy ? null : _submit,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------- widgets

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(top: 26, bottom: 12),
    child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
  );

  InputDecoration _decoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white70),
    filled: true,
    fillColor: AppColors.surfaceDark,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
  );

  Widget _select<T>(
      String label,
      T value,
      List<T> values,
      ValueChanged<T> onChanged, {
        String Function(T)? labelOf,
      }) {
    return DropdownButtonFormField<T>(
      value: value,
      dropdownColor: AppColors.surfaceDark,
      style: const TextStyle(color: Colors.white),
      decoration: _decoration(label),
      items: values
          .map((item) => DropdownMenuItem<T>(value: item, child: Text(labelOf != null ? labelOf(item) : item.toString())))
          .toList(),
      onChanged: (item) {
        if (item != null) onChanged(item);
      },
    );
  }

  Widget _dateField({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime> onPicked,
    required String? Function() validator,
  }) {
    return FormField<DateTime>(
      validator: (_) => validator(),
      builder: (field) => InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          final picked = await _pickDateTime(value);
          if (picked != null) {
            onPicked(picked);
            field.didChange(picked);
          }
        },
        child: InputDecorator(
          decoration: _decoration(label).copyWith(
            errorText: field.errorText,
            suffixIcon: const Icon(Icons.calendar_month, color: Colors.white54),
          ),
          child: Text(
            value == null ? 'Select date & time' : _format(value),
            style: TextStyle(color: value == null ? Colors.white38 : Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _bannerPicker() {
    final hasNew = _newBanner != null;
    final hasExisting = !_removeBanner && _existingBannerUrl != null && _existingBannerUrl!.isNotEmpty;

    Widget preview;
    if (hasNew) {
      preview = Image.file(_newBanner!, fit: BoxFit.cover);
    } else if (hasExisting) {
      preview = Image.network(
        _existingBannerUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image_outlined, color: Colors.white38)),
      );
    } else {
      preview = const Center(child: Icon(Icons.image_outlined, color: Colors.white38, size: 40));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(color: AppColors.surfaceDark, child: preview),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _pickBanner,
              icon: const Icon(Icons.upload_outlined, size: 18),
              label: Text(hasNew || hasExisting ? 'Change' : 'Choose image'),
            ),
            const SizedBox(width: 10),
            if (hasNew || hasExisting)
              TextButton(
                onPressed: () => setState(() {
                  _newBanner = null;
                  if (hasExisting) _removeBanner = true;
                }),
                child: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
              ),
          ],
        ),
      ],
    );
  }

  // ------------------------------------------------------------- helpers

  Future<void> _pickBanner() async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1280, imageQuality: 70);
      if (picked == null) return;
      setState(() {
        _newBanner = File(picked.path);
        _removeBanner = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not pick image: $e')));
    }
  }

  Future<DateTime?> _pickDateTime(DateTime? initial) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial ?? now),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String _format(DateTime d) {
    final time = TimeOfDay.fromDateTime(d).format(context);
    return '${d.day} ${_kMonths[d.month - 1]} ${d.year}, $time';
  }

  String? _required(String? v) => v == null || v.trim().isEmpty ? 'Required' : null;

  String? _nonNegativeNumber(String? v) {
    final n = double.tryParse(v ?? '');
    if (n == null) return 'Enter a number';
    if (n < 0) return 'Cannot be negative';
    return null;
  }

  String? _maxSlots(String? v) {
    final n = int.tryParse(v ?? '');
    if (n == null || n < 2) return 'Enter at least 2';
    if (!_isNew && n < _currentParticipants) return '$_currentParticipants already registered';
    return null;
  }

  // -------------------------------------------------------------- submit

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final controller = ref.read(tournamentAdminActionsControllerProvider.notifier);

    final data = <String, dynamic>{
      'name': _name.text.trim(),
      'description': _description.text.trim(),
      'game': _kGame,
      'mode': _mode.name,
      'matchType': _matchType,
      'map': _map.text.trim(),
      'entryFee': double.parse(_entryFee.text),
      'prizePool': double.parse(_prizePool.text),
      'maxParticipants': int.parse(_maxTeams.text),
      'registrationStart': Timestamp.fromDate(_regStart!),
      'registrationEnd': Timestamp.fromDate(_regEnd!),
      'startTime': Timestamp.fromDate(_date!),
      'rules': _rules.text.trim(),
      'isPublished': _published,
      'status': (_isNew ? TournamentStatus.upcoming : _stage).name,
    };

    final bool ok;
    if (_isNew) {
      data['createdBy'] = FirebaseAuth.instance.currentUser?.uid ?? '';
      ok = await controller.create(data, banner: _newBanner);
    } else {
      ok = await controller.update(
        widget.tournamentId,
        data,
        banner: _newBanner,
        removeBanner: _removeBanner,
      );
    }

    if (ok) {
      messenger.showSnackBar(SnackBar(
        content: Text(
          (_isNew ? 'Tournament created' : 'Changes saved') +
              (_newBanner != null ? ' · banner uploading in background' : ''),
        ),
      ));
      navigator.pop();
    } else {
      final error = ref.read(tournamentAdminActionsControllerProvider).error;
      messenger.showSnackBar(SnackBar(content: Text('Could not save: $error')));
    }
  }
}