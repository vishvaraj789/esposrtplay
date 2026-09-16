import 'package:flutter/material.dart';

import '../provider/chat_provider.dart';

const _kMyBubble = Color(0xFFFF3D5A);
const _kOtherBubble = Color(0xFF171821);
const _kHairline = Color(0xFF2A2C38);
const _kTextSecondary = Color(0xFF9CA0AF);

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final bool showSenderName; // useful in team chat (group), not needed 1:1

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showSenderName = false,
  });

  String _time(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? _kMyBubble : _kOtherBubble,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isMe ? 14 : 2),
            bottomRight: Radius.circular(isMe ? 2 : 14),
          ),
          border: isMe ? null : Border.all(color: _kHairline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showSenderName && !isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(message.senderName,
                    style: const TextStyle(color: Color(0xFF3DA9FC), fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            Text(message.text, style: const TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 3),
            Text(
              _time(message.createdAt),
              style: TextStyle(color: isMe ? Colors.white70 : _kTextSecondary, fontSize: 9.5),
            ),
          ],
        ),
      ),
    );
  }
}