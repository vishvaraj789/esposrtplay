import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/provider/auth_provider.dart';
import '../provider/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/message_input.dart';

const _kBg = Color(0xFF0F172A);
const _kTextSecondary = Color(0xFF9CA0AF);

/// 1:1 direct message screen between the signed-in user and [otherUid].
class ChatScreen extends ConsumerStatefulWidget {
  final String otherUid;
  final String otherUserName;

  const ChatScreen({super.key, required this.otherUid, required this.otherUserName});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final myUid = authState.value?.uid;
    final myName = authState.value?.displayName ?? 'Me';

    if (myUid == null) {
      return const Scaffold(
        backgroundColor: _kBg,
        body: Center(child: Text('Please log in', style: TextStyle(color: _kTextSecondary))),
      );
    }

    final chatId = ref.read(chatRepositoryProvider).directChatId(myUid, widget.otherUid);
    final messagesAsync = ref.watch(directMessagesProvider(chatId));

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(title: Text(widget.otherUserName), backgroundColor: _kBg, elevation: 0),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
              data: (messages) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                if (messages.isEmpty) {
                  return const Center(child: Text('Say hello 👋', style: TextStyle(color: _kTextSecondary)));
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final m = messages[i];
                    return ChatBubble(message: m, isMe: m.senderId == myUid);
                  },
                );
              },
            ),
          ),
          MessageInput(
            onSend: (text) {
              ref.read(chatRepositoryProvider).sendDirectMessage(
                chatId: chatId,
                participantUids: [myUid, widget.otherUid],
                senderId: myUid,
                senderName: myName,
                text: text,
              );
            },
          ),
        ],
      ),
    );
  }
}