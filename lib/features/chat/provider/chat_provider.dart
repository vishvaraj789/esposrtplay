import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
  });

  factory ChatMessage.fromFirestore(String id, Map<String, dynamic> data) {
    return ChatMessage(
      id: id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? 'Unknown',
      text: data['text'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Deterministic chat id for two users — always the same regardless of
  /// who initiates, so both sides land on the same doc.
  String directChatId(String uidA, String uidB) {
    final sorted = [uidA, uidB]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  // --- Direct (1:1) chats ---

  Stream<List<ChatMessage>> watchDirectMessages(String chatId) {
    return _firestore
        .collection('direct_chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs.map((d) => ChatMessage.fromFirestore(d.id, d.data())).toList());
  }

  Future<void> sendDirectMessage({
    required String chatId,
    required List<String> participantUids,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    final chatRef = _firestore.collection('direct_chats').doc(chatId);

    await chatRef.set({
      'participants': participantUids,
      'lastMessage': text.trim(),
      'lastMessageAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await chatRef.collection('messages').add({
      'senderId': senderId,
      'senderName': senderName,
      'text': text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // --- Team chats ---

  Stream<List<ChatMessage>> watchTeamMessages(String teamId) {
    return _firestore
        .collection('teams')
        .doc(teamId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs.map((d) => ChatMessage.fromFirestore(d.id, d.data())).toList());
  }

  Future<void> sendTeamMessage({
    required String teamId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    await _firestore.collection('teams').doc(teamId).collection('messages').add({
      'senderId': senderId,
      'senderName': senderName,
      'text': text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) => ChatRepository());

final directMessagesProvider = StreamProvider.family<List<ChatMessage>, String>((ref, chatId) {
  return ref.watch(chatRepositoryProvider).watchDirectMessages(chatId);
});

final teamMessagesProvider = StreamProvider.family<List<ChatMessage>, String>((ref, teamId) {
  return ref.watch(chatRepositoryProvider).watchTeamMessages(teamId);
});