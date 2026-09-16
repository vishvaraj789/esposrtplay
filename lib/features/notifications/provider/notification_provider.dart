import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/provider/auth_provider.dart';

enum NotificationType { tournament, wallet, team, general }

NotificationType _typeFromString(String s) =>
    NotificationType.values.firstWhere((e) => e.name == s, orElse: () => NotificationType.general);

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
  });

  factory NotificationItem.fromFirestore(String id, Map<String, dynamic> data) {
    return NotificationItem(
      id: id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: _typeFromString(data['type'] ?? 'general'),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

IconData iconFor(NotificationType type) {
  switch (type) {
    case NotificationType.tournament:
      return Icons.emoji_events;
    case NotificationType.wallet:
      return Icons.account_balance_wallet;
    case NotificationType.team:
      return Icons.groups;
    case NotificationType.general:
      return Icons.notifications;
  }
}

Color colorFor(NotificationType type) {
  switch (type) {
    case NotificationType.tournament:
      return const Color(0xFFFFC24B);
    case NotificationType.wallet:
      return const Color(0xFF3DDC84);
    case NotificationType.team:
      return const Color(0xFF3DA9FC);
    case NotificationType.general:
      return const Color(0xFF9CA0AF);
  }
}

/// Streams the signed-in user's notifications, newest first.
/// Returns an empty list (not an error) when signed out.
final notificationsProvider = StreamProvider<List<NotificationItem>>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(<NotificationItem>[]);
      return FirebaseFirestore.instance
          .collection('notifications')
          .doc(user.uid)
          .collection('items')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map((d) => NotificationItem.fromFirestore(d.id, d.data())).toList());
    },
    loading: () => Stream.value(<NotificationItem>[]),
    error: (_, __) => Stream.value(<NotificationItem>[]),
  );
});