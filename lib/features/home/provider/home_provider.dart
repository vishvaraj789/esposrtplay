import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../routes/route_names.dart';

// --- Data models ---

class BannerItem {
  final String tag;
  final String statusLabel;
  final Color statusColor;
  final String title;
  final String dateLabel;
  final String modeLabel;
  final String prize;

  /// Optional: id of the tournament this banner promotes. When absent, JOIN NOW
  /// opens the Tournaments tab instead.
  final String? tournamentId;

  const BannerItem({
    required this.tag,
    required this.statusLabel,
    required this.statusColor,
    required this.title,
    required this.dateLabel,
    required this.modeLabel,
    required this.prize,
    this.tournamentId,
  });

  factory BannerItem.fromFirestore(Map<String, dynamic> data) {
    final tid = data['tournamentId'];
    return BannerItem(
      tag: data['tag'] ?? '',
      statusLabel: data['statusLabel'] ?? 'OPEN',
      statusColor: Color(data['statusColor'] ?? 0xFF3DDC84),
      title: data['title'] ?? '',
      dateLabel: data['dateLabel'] ?? '',
      modeLabel: data['modeLabel'] ?? '',
      prize: data['prize'] ?? '',
      tournamentId: tid is String && tid.isNotEmpty ? tid : null,
    );
  }
}

class QuickAction {
  final IconData icon;
  final Color color;
  final String label;
  final String? route;

  const QuickAction({
    required this.icon,
    required this.color,
    required this.label,
    this.route,
  });
}

class GameItem {
  final String id;
  final String name;
  final String iconAsset;
  final int activePlayers;

  const GameItem({
    required this.id,
    required this.name,
    required this.iconAsset,
    required this.activePlayers,
  });

  factory GameItem.fromFirestore(String id, Map<String, dynamic> data) {
    return GameItem(
      id: id,
      name: data['name'] ?? '',
      iconAsset: data['iconAsset'] ?? '',
      activePlayers: data['activePlayers'] ?? 0,
    );
  }
}

// --- Firestore-backed providers ---

final _firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final bannersProvider = StreamProvider<List<BannerItem>>((ref) {
  final firestore = ref.watch(_firestoreProvider);
  return firestore
      .collection('banners')
      .orderBy('order')
      .snapshots()
      .map((snap) => snap.docs.map((d) => BannerItem.fromFirestore(d.data())).toList());
});

final gamesProvider = StreamProvider<List<GameItem>>((ref) {
  final firestore = ref.watch(_firestoreProvider);
  return firestore
      .collection('games')
      .snapshots()
      .map((snap) => snap.docs.map((d) => GameItem.fromFirestore(d.id, d.data())).toList());
});

// --- Static, non-Firestore data ---

final quickActionsProvider = Provider<List<QuickAction>>((ref) {
  return const [
    QuickAction(icon: Icons.emoji_events, color: Color(0xFFFFC24B), label: 'Tournaments', route: Routes.tournaments),
    QuickAction(icon: Icons.groups, color: Color(0xFF3DDC84), label: 'My Team', route: Routes.teams),
    QuickAction(icon: Icons.search, color: Color(0xFF3DA9FC), label: 'Find Players'),
    QuickAction(icon: Icons.account_balance_wallet, color: Color(0xFFFFC24B), label: 'Wallet', route: Routes.wallet),
    QuickAction(icon: Icons.card_giftcard, color: Color(0xFFFF3D5A), label: 'Rewards'),
    QuickAction(icon: Icons.podcasts, color: Color(0xFFE23744), label: 'Live Match', route: Routes.matches),
    QuickAction(icon: Icons.history, color: Color(0xFF3DA9FC), label: 'History', route: Routes.walletTransactions),
    QuickAction(icon: Icons.headset_mic, color: Color(0xFF8B5CF6), label: 'Support'),
  ];
});