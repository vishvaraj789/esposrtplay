import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/empty_widget.dart';
import '../../../routes/route_names.dart';
import '../../auth/provider/auth_provider.dart';
import '../model/tournament_model.dart';
import '../provider/tournament_provider.dart';
import '../widgets/participant_tile.dart';
import '../widgets/prize_card.dart';

const _kBg = Color(0xFF0B0C12);
const _kCard = Color(0xFF171821);
const _kHairline = Color(0xFF2A2C38);
const _kTextSecondary = Color(0xFF9CA0AF);
const _kGold = Color(0xFFFFC24B);
const _kGreen = Color(0xFF3DDC84);
const _kPurple = Color(0xFF8B5CF6);
const _kBrandGradient = LinearGradient(
  colors: [Color(0xFFFF6A3D), Color(0xFFFF3D5A)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

String _cleanError(Object? e) =>
    (e?.toString() ?? 'Something went wrong').replaceFirst('Exception: ', '');

String _formatStart(DateTime date) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final d = date.toLocal();
  final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final minute = d.minute.toString().padLeft(2, '0');
  final period = d.hour >= 12 ? 'PM' : 'AM';
  return '${d.day} ${months[d.month - 1]} · $hour:$minute $period';
}

/// Live tournament details: status, schedule, slots, prizes, registered teams,
/// and a captain-only "Register" action.
class TournamentDetailsScreen extends ConsumerWidget {
  final String tournamentId;

  const TournamentDetailsScreen({super.key, required this.tournamentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournamentAsync = ref.watch(tournamentDetailProvider(tournamentId));

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        centerTitle: true,
        title: const Text('Tournament', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: tournamentAsync.when(
        loading: () => const AppLoader(),
        error: (e, _) => const EmptyWidget(
          icon: Icons.error_outline,
          message: 'Could not load this tournament.\nCheck your connection and try again.',
        ),
        data: (tournament) {
          if (tournament == null) {
            return const EmptyWidget(icon: Icons.search_off, message: 'Tournament not found');
          }
          return _Body(tournament: tournament);
        },
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  final Tournament tournament;

  const _Body({required this.tournament});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regsAsync = ref.watch(registrationsProvider(tournament.id));
    final registrations = regsAsync.value ?? const <TeamRegistration>[];

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _HeaderCard(tournament: tournament),
              const SizedBox(height: 14),
              _InfoGrid(tournament: tournament),
              const SizedBox(height: 14),
              if (tournament.prizeBreakdown.isNotEmpty) ...[
                PrizeCard(breakdown: tournament.prizeBreakdown),
                const SizedBox(height: 14),
              ],
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.push(Routes.tournamentBracketPath(tournament.id)),
                  icon: const Icon(Icons.account_tree_outlined, color: _kPurple, size: 18),
                  label: const Text('View Bracket',
                      style: TextStyle(color: _kPurple, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: const BorderSide(color: _kPurple, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Registered Teams',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  Text('${tournament.currentParticipants}/${tournament.maxParticipants}',
                      style: const TextStyle(color: _kTextSecondary, fontSize: 12.5)),
                ],
              ),
              const SizedBox(height: 10),
              regsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: AppLoader(size: 24),
                ),
                error: (e, _) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Could not load teams', style: TextStyle(color: _kTextSecondary)),
                ),
                data: (regs) {
                  if (regs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('No teams registered yet', style: TextStyle(color: _kTextSecondary)),
                    );
                  }
                  return Container(
                    decoration: BoxDecoration(
                      color: _kCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _kHairline),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    child: Column(
                      children: regs.map((r) => ParticipantTile(registration: r)).toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        _RegisterBar(tournament: tournament, registrations: registrations),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final Tournament tournament;

  const _HeaderCard({required this.tournament});

  Color get _statusColor {
    switch (tournament.status) {
      case TournamentStatus.live:
        return const Color(0xFFE23744);
      case TournamentStatus.upcoming:
        return const Color(0xFFFF6A3D);
      case TournamentStatus.completed:
      case TournamentStatus.cancelled:
        return _kTextSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kPurple.withOpacity(0.45)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(gradient: _kBrandGradient, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.emoji_events, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tournament.name,
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('${tournament.mode.name.toUpperCase()} • ${tournament.map}',
                    style: const TextStyle(color: _kTextSecondary, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: _statusColor, borderRadius: BorderRadius.circular(6)),
            child: Text(tournament.status.name.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final Tournament tournament;

  const _InfoGrid({required this.tournament});

  @override
  Widget build(BuildContext context) {
    final fee = tournament.entryFee <= 0 ? 'Free' : '₹${tournament.entryFee.toStringAsFixed(0)}';
    final max = tournament.maxParticipants;
    final progress = max <= 0 ? 0.0 : (tournament.currentParticipants / max).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kHairline),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _InfoTile(label: 'Starts', value: _formatStart(tournament.startTime))),
              Expanded(child: _InfoTile(label: 'Entry Fee', value: fee)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  label: 'Prize Pool',
                  value: '₹${tournament.prizePool.toStringAsFixed(0)}',
                  valueColor: _kGreen,
                ),
              ),
              Expanded(
                child: _InfoTile(
                  label: 'Slots',
                  value: '${tournament.currentParticipants}/${tournament.maxParticipants}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: _kHairline,
              valueColor: const AlwaysStoppedAnimation<Color>(_kGold),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _InfoTile({required this.label, required this.value, this.valueColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: _kTextSecondary, fontSize: 11)),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(color: valueColor, fontSize: 14, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

/// Bottom action bar. Works out which of the possible states the viewer is in
/// (closed / full / already in / no team / not captain / ready) and shows the
/// matching label; only the "ready" state is tappable to register.
class _RegisterBar extends ConsumerWidget {
  final Tournament tournament;
  final List<TeamRegistration> registrations;

  const _RegisterBar({required this.tournament, required this.registrations});

  Future<void> _register(BuildContext context, WidgetRef ref, Team team) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: 'Register ${team.name}?',
      message: 'Your team will take a slot in ${tournament.name}.',
      confirmText: 'Register',
    );
    if (confirmed != true || !context.mounted) return;

    // TODO: entry fees are not charged yet. When wallet deduction is wired,
    // it should happen atomically with registerTeam (same transaction).
    final ok = await ref.read(registerTeamControllerProvider.notifier).register(
      tournamentId: tournament.id,
      teamId: team.id,
      teamName: team.name,
      logoUrl: team.logoUrl,
    );
    if (!context.mounted) return;

    final message =
    ok ? 'Team registered!' : _cleanError(ref.read(registerTeamControllerProvider).error);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authStateProvider).value?.uid;
    final teamsAsync = uid == null ? null : ref.watch(userTeamsProvider(uid));
    final isRegistering = ref.watch(registerTeamControllerProvider).isLoading;

    final teams = teamsAsync?.value ?? const <Team>[];
    final captainTeam = teams.where((t) => t.captainUid == uid).firstOrNull;
    final alreadyRegistered = registrations.any((r) => teams.any((t) => t.id == r.teamId));

    String label;
    IconData icon = Icons.how_to_reg;
    VoidCallback? onTap;

    if (tournament.status != TournamentStatus.upcoming) {
      label = 'Registration closed';
      icon = Icons.lock_outline;
    } else if (alreadyRegistered) {
      label = 'Your team is registered';
      icon = Icons.check_circle_outline;
    } else if (tournament.isFull) {
      label = 'Tournament full';
      icon = Icons.block;
    } else if (teamsAsync == null || (teamsAsync.isLoading && teams.isEmpty)) {
      label = 'Loading…';
    } else if (teams.isEmpty) {
      label = 'Create a team to join';
      icon = Icons.add;
      onTap = () => context.push(Routes.teamCreate);
    } else if (captainTeam == null) {
      label = 'Only your team captain can register';
      icon = Icons.workspace_premium;
    } else {
      label = 'Register ${captainTeam.name}';
      onTap = () => _register(context, ref, captainTeam);
    }

    final enabled = onTap != null && !isRegistering;

    return Container(
      decoration: const BoxDecoration(
        color: _kBg,
        border: Border(top: BorderSide(color: _kHairline)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: enabled ? _kBrandGradient : null,
              color: enabled ? null : _kCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton.icon(
              onPressed: enabled ? onTap : null,
              icon: isRegistering
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
              )
                  : Icon(icon, color: enabled ? Colors.white : _kTextSecondary, size: 18),
              label: Text(
                label,
                style: TextStyle(
                  color: enabled ? Colors.white : _kTextSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}