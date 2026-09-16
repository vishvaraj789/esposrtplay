import 'package:flutter/material.dart';

import '../models/announcement_model.dart';

const _kCard = Color(0xFF171821);
const _kHairline = Color(0xFF2A2C38);
const _kTextSecondary = Color(0xFF9CA0AF);
const _kBlue = Color(0xFF3DA9FC);

class AnnouncementCard extends StatelessWidget {
  final AnnouncementModel announcement;
  final VoidCallback? onDelete;

  const AnnouncementCard({super.key, required this.announcement, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: _kHairline)),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.campaign, color: _kBlue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(announcement.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(announcement.message, style: const TextStyle(color: _kTextSecondary, fontSize: 12.5)),
                const SizedBox(height: 6),
                Text(
                  '${announcement.createdAt.day}/${announcement.createdAt.month}/${announcement.createdAt.year}',
                  style: const TextStyle(color: _kTextSecondary, fontSize: 10.5),
                ),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18), onPressed: onDelete),
        ],
      ),
    );
  }
}