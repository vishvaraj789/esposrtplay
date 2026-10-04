import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/user_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_textfield.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/team_provider.dart';
import '../repository/team_repository.dart';

/// Team actions shared by the Teams tab and the Team details page, so the
/// leave / invite / join / member-management flows exist in exactly one place.

String cleanTeamError(Object e) => e.toString().replaceFirst('Exception: ', '');

void showTeamSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Asks for confirmation, then leaves the team. Returns true if the user left.
/// The repository refuses to let a captain leave; that message is surfaced.
Future<bool> confirmAndLeaveTeam(
    BuildContext context,
    WidgetRef ref, {
      required TeamModel team,
      required String uid,
    }) async {
  final ok = await AppDialog.confirm(
    context,
    title: 'Leave ${team.name}?',
    message: "You'll need a new invite code to rejoin.",
    confirmText: 'Leave',
    isDanger: true,
  );
  if (ok != true || !context.mounted) return false;
  try {
    await ref.read(teamRepositoryProvider).leaveTeam(teamId: team.id, uid: uid);
    return true;
  } catch (e) {
    if (context.mounted) showTeamSnack(context, cleanTeamError(e));
    return false;
  }
}

/// Captain-only menu for another member: make captain / remove from team.
Future<void> showTeamMemberMenu(
    BuildContext context,
    WidgetRef ref, {
      required TeamModel team,
      required TeamMember member,
      required String myUid,
    }) async {
  final action = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.workspace_premium, color: AppColors.gold),
            title: const Text('Make captain', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.of(ctx).pop('captain'),
          ),
          ListTile(
            leading: const Icon(Icons.person_remove_outlined, color: AppColors.pink),
            title: const Text('Remove from team', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.of(ctx).pop('remove'),
          ),
        ],
      ),
    ),
  );
  if (action == null || !context.mounted) return;

  final repo = ref.read(teamRepositoryProvider);

  if (action == 'captain') {
    final ok = await AppDialog.confirm(
      context,
      title: 'Make ${member.name} captain?',
      message: 'You will lose captain controls for this team.',
      confirmText: 'Transfer',
    );
    if (ok != true || !context.mounted) return;
    try {
      await repo.transferCaptain(teamId: team.id, newCaptainUid: member.uid, oldCaptainUid: myUid);
      if (context.mounted) showTeamSnack(context, '${member.name} is now captain');
    } catch (e) {
      if (context.mounted) showTeamSnack(context, cleanTeamError(e));
    }
  } else if (action == 'remove') {
    final ok = await AppDialog.confirm(
      context,
      title: 'Remove ${member.name}?',
      message: 'They will be removed from the squad.',
      confirmText: 'Remove',
      isDanger: true,
    );
    if (ok != true || !context.mounted) return;
    try {
      await repo.removeMember(teamId: team.id, uid: member.uid);
      if (context.mounted) showTeamSnack(context, '${member.name} removed');
    } catch (e) {
      if (context.mounted) showTeamSnack(context, cleanTeamError(e));
    }
  }
}

/// Shows the team's invite code with a copy button.
Future<void> showInviteCodeSheet(BuildContext context, TeamModel team) {
  final spotsLeft = (team.maxMembers - team.memberUids.length).clamp(0, team.maxMembers);
  final messenger = ScaffoldMessenger.of(context);

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Invite teammates',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
              spotsLeft == 0
                  ? '${team.name} is full right now.'
                  : '$spotsLeft ${spotsLeft == 1 ? 'spot' : 'spots'} left. Share this code so they can join.',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.backgroundDeep,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.hairline),
              ),
              child: Center(
                child: SelectableText(
                  team.inviteCode.isEmpty ? '—' : team.inviteCode,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 6),
                ),
              ),
            ),
            const SizedBox(height: 14),
            AppButton(
              text: 'Copy code',
              icon: Icons.copy_rounded,
              onPressed: team.inviteCode.isEmpty
                  ? null
                  : () async {
                await Clipboard.setData(ClipboardData(text: team.inviteCode));
                if (ctx.mounted) Navigator.of(ctx).pop();
                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(const SnackBar(content: Text('Invite code copied')));
              },
            ),
          ],
        ),
      ),
    ),
  );
}

/// Bottom sheet that asks for an invite code and joins the team.
/// Resolves to the joined team's id, or null if dismissed.
Future<String?> showJoinTeamSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => const _JoinTeamSheet(),
  );
}

class _JoinTeamSheet extends ConsumerStatefulWidget {
  const _JoinTeamSheet();

  @override
  ConsumerState<_JoinTeamSheet> createState() => _JoinTeamSheetState();
}

class _JoinTeamSheetState extends ConsumerState<_JoinTeamSheet> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  String? _validate(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Enter the invite code';
    if (!RegExp(r'^[A-Za-z0-9]{4,10}$').hasMatch(value)) return 'Invite codes are letters and numbers only';
    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authStateProvider).value;
    if (user == null) {
      setState(() => _error = 'You need to be signed in to join a team.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    String? joinedId;
    String? error;
    try {
      // One team per user (see TeamRepository.watchUserTeam); joinByInviteCode
      // doesn't enforce that itself, so check here first.
      final existing = await ref.read(userTeamProvider(user.uid).future);
      if (existing != null) {
        error = 'You are already on a team. Leave it before joining another.';
      } else {
        final profile = await UserService.instance.getUserProfile(user.uid);
        String field(String key) => (profile?[key] as String?)?.trim() ?? '';
        final nickname = field('nickname');
        final fullName = field('fullName');
        final role = field('inGameRole');

        joinedId = await ref.read(joinTeamControllerProvider.notifier).join(
          inviteCode: _codeCtrl.text.trim().toUpperCase(),
          uid: user.uid,
          name: nickname.isNotEmpty ? nickname : (fullName.isNotEmpty ? fullName : 'Player'),
          role: role.isNotEmpty ? role : 'Player',
        );
        if (joinedId == null) {
          final raw = ref.read(joinTeamControllerProvider).error;
          error = cleanTeamError(raw ?? 'Could not join the team.');
        }
      }
    } catch (e) {
      error = cleanTeamError(e);
    }

    if (!mounted) return;
    if (joinedId != null) {
      Navigator.of(context).pop(joinedId);
      return;
    }
    setState(() {
      _submitting = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        // AppTextField takes its colours from the ambient theme; force dark.
        child: Theme(
          data: ThemeData.dark(),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Join a team',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('Ask your captain for the invite code from their team page.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _codeCtrl,
                  label: 'Invite Code',
                  hint: 'e.g. K7M2QX',
                  icon: Icons.vpn_key_outlined,
                  validator: _validate,
                  enabled: !_submitting,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AppColors.pink, fontSize: 13)),
                ],
                const SizedBox(height: 18),
                AppButton(
                  text: 'Join Team',
                  icon: Icons.login,
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