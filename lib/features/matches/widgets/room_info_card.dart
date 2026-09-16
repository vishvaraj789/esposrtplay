import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _kCard = Color(0xFF171821);
const _kHairline = Color(0xFF2A2C38);
const _kGold = Color(0xFFFFC24B);
const _kTextSecondary = Color(0xFF9CA0AF);

/// Shows room ID/password once a match is live. Room info stays hidden
/// (with a placeholder) if the match hasn't started yet.
class RoomInfoCard extends StatelessWidget {
  final String? roomId;
  final String? roomPassword;

  const RoomInfoCard({super.key, this.roomId, this.roomPassword});

  void _copy(BuildContext context, String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied'), duration: const Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasInfo = roomId != null && roomPassword != null;

    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kHairline),
      ),
      padding: const EdgeInsets.all(16),
      child: hasInfo
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Room Details', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _row(context, 'Room ID', roomId!),
          const SizedBox(height: 10),
          _row(context, 'Password', roomPassword!),
        ],
      )
          : const Row(
        children: [
          Icon(Icons.lock_clock, color: _kTextSecondary, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text('Room details will appear here once the match starts',
                style: TextStyle(color: _kTextSecondary, fontSize: 12.5)),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(color: _kTextSecondary, fontSize: 12.5))),
        Expanded(
          child: Text(value, style: const TextStyle(color: _kGold, fontSize: 15, fontWeight: FontWeight.w700)),
        ),
        GestureDetector(
          onTap: () => _copy(context, label, value),
          child: const Icon(Icons.copy, color: _kTextSecondary, size: 17),
        ),
      ],
    );
  }
}