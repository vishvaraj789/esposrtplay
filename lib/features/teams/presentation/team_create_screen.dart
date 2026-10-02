import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/user_service.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_textfield.dart';
import '../../../routes/route_names.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/team_provider.dart';

const _kBg = Color(0xFF0B0C12);
const _kCard = Color(0xFF171821);
const _kHairline = Color(0xFF2A2C38);
const _kTextSecondary = Color(0xFF9CA0AF);
const _kPink = Color(0xFFFF3D5A);
const _kBrandGradient = LinearGradient(
  colors: [Color(0xFFFF6A3D), Color(0xFFFF3D5A)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

/// Create a squad. The creator becomes captain; the team starts with one
/// member and an invite code that others can use to join.
class TeamCreateScreen extends ConsumerStatefulWidget {
  const TeamCreateScreen({super.key});

  @override
  ConsumerState<TeamCreateScreen> createState() => _TeamCreateScreenState();
}

class _TeamCreateScreenState extends ConsumerState<TeamCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();

  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  String? _validateName(String? v) {
    final value = (v ?? '').trim();
    if (value.length < 3) return 'Team name must be at least 3 characters';
    if (value.length > 24) return 'Team name must be 24 characters or fewer';
    return null;
  }

  String? _validateTag(String? v) {
    final value = (v ?? '').trim();
    if (!RegExp(r'^[A-Za-z0-9]{2,5}$').hasMatch(value)) {
      return 'Tag must be 2–5 letters or numbers';
    }
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authStateProvider).value;
    if (user == null) {
      setState(() => _error = 'You need to be signed in to create a team.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    String? newTeamId;
    String? error;

    try {
      // A user can be on at most one team (see TeamRepository.watchUserTeam),
      // and createTeam doesn't enforce that itself, so check here first.
      final existing = await ref.read(userTeamProvider(user.uid).future);
      if (existing != null) {
        error = 'You are already on a team. Leave it before creating a new one.';
      } else {
        final profile = await UserService.instance.getUserProfile(user.uid);
        final nickname = (profile?['nickname'] as String?)?.trim() ?? '';
        final fullName = (profile?['fullName'] as String?)?.trim() ?? '';
        final inGameRole = (profile?['inGameRole'] as String?)?.trim() ?? '';

        newTeamId = await ref.read(createTeamControllerProvider.notifier).create(
          name: _nameCtrl.text.trim(),
          tag: _tagCtrl.text.trim().toUpperCase(),
          captainUid: user.uid,
          captainName: nickname.isNotEmpty ? nickname : (fullName.isNotEmpty ? fullName : 'Captain'),
          captainRole: inGameRole.isNotEmpty ? inGameRole : 'Player',
        );

        if (newTeamId == null) {
          final raw = ref.read(createTeamControllerProvider).error;
          error = (raw?.toString() ?? 'Could not create the team.').replaceFirst('Exception: ', '');
        }
      }
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    }

    if (!mounted) return;
    setState(() {
      _submitting = false;
      _error = error;
    });

    if (newTeamId != null) {
      context.pushReplacement(Routes.teamDetailsPath(newTeamId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        centerTitle: true,
        title: const Text('Create Team', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      // AppTextField picks its colours from the ambient theme; force dark so
      // labels stay readable on this screen's dark background.
      body: Theme(
        data: ThemeData.dark(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(gradient: _kBrandGradient, borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.shield, color: Colors.white, size: 42),
                  ),
                ),
                const SizedBox(height: 22),
                AppTextField(
                  controller: _nameCtrl,
                  label: 'Team Name',
                  hint: 'e.g. ESP Warriors',
                  icon: Icons.groups_outlined,
                  validator: _validateName,
                  enabled: !_submitting,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _tagCtrl,
                  label: 'Team Tag',
                  hint: 'e.g. ESPW',
                  icon: Icons.tag,
                  validator: _validateTag,
                  enabled: !_submitting,
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: _kCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _kHairline),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: _kTextSecondary, size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "You'll be the team captain. Squads hold up to 4 players — "
                              'share your invite code from the team page to bring them in.',
                          style: TextStyle(color: _kTextSecondary, fontSize: 12.5, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(_error!, style: const TextStyle(color: _kPink, fontSize: 13)),
                ],
                const SizedBox(height: 24),
                AppButton(
                  text: 'Create Team',
                  icon: Icons.check,
                  isLoading: _submitting,
                  onPressed: _submitting ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}