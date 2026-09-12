import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Data models ---

class BannerItem {
  final String tag;
  final String statusLabel;
  final Color statusColor;
  final String title;
  final String dateLabel;
  final String modeLabel;
  final String prize;
  final VoidCallback? onJoin;

  const BannerItem({
    required this.tag,
    required this.statusLabel,
    required this.statusColor,
    required this.title,
    required this.dateLabel,
    required this.modeLabel,
    required this.prize,
    this.onJoin,
  });

  factory BannerItem.fromFirestore(Map<String, dynamic> data) {
    return BannerItem(
      tag: data['tag'] ?? '',
      statusLabel: data['statusLabel'] ?? 'OPEN',
      statusColor: Color(data['statusColor'] ?? 0xFF3DDC84),
      title: data['title'] ?? '',
      dateLabel: data['dateLabel'] ?? '',
      modeLabel: data['modeLabel'] ?? '',
      prize: data['prize'] ?? '',
    );
  }
}

class TournamentItem {
  final String id;
  final String name;
  final String badge;
  final Color badgeColor;
  final String time;
  final String entry;
  final String prize;

  const TournamentItem({
    required this.id,
    required this.name,
    required this.badge,
    required this.badgeColor,
    required this.time,
    required this.entry,
    required this.prize,
  });

  factory TournamentItem.fromFirestore(String id, Map<String, dynamic> data) {
    return TournamentItem(
      id: id,
      name: data['name'] ?? '',
      badge: data['badge'] ?? 'OPEN',
      badgeColor: Color(data['badgeColor'] ?? 0xFF3DDC84),
      time: data['time'] ?? '',
      entry: data['entry'] ?? '',
      prize: data['prize'] ?? '',
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

final tournamentsProvider = StreamProvider<List<TournamentItem>>((ref) {
  final firestore = ref.watch(_firestoreProvider);
  return firestore
      .collection('tournaments')
      .orderBy('startTime')
      .limit(10)
      .snapshots()
      .map((snap) => snap.docs
      .map((d) => TournamentItem.fromFirestore(d.id, d.data()))
      .toList());
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
    QuickAction(icon: Icons.emoji_events, color: Color(0xFFFFC24B), label: 'Tournaments'),
    QuickAction(icon: Icons.groups, color: Color(0xFF3DDC84), label: 'My Team'),
    QuickAction(icon: Icons.search, color: Color(0xFF3DA9FC), label: 'Find Players'),
    QuickAction(icon: Icons.account_balance_wallet, color: Color(0xFFFFC24B), label: 'Wallet'),
    QuickAction(icon: Icons.card_giftcard, color: Color(0xFFFF3D5A), label: 'Rewards'),
    QuickAction(icon: Icons.podcasts, color: Color(0xFFE23744), label: 'Live Match'),
    QuickAction(icon: Icons.history, color: Color(0xFF3DA9FC), label: 'History'),
    QuickAction(icon: Icons.headset_mic, color: Color(0xFF8B5CF6), label: 'Support'),
  ];
});