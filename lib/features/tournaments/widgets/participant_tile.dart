import 'package:flutter/material.dart';

import '../model/tournament_model.dart';

const _kHairline = Color(0xFF2A2C38);
const _kGreen = Color(0xFF3DDC84);
const _kTextSecondary = Color(0xFF9CA0AF);

class ParticipantTile extends StatelessWidget {
  final TeamRegistration registration;
  final VoidCallback? onTap;

  const ParticipantTile({super.key, required this.registration, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: _kHairline,
        backgroundImage: registration.logoUrl != null ? NetworkImage(registration.logoUrl!) : null,
        child: registration.logoUrl == null
            ? Text(registration.teamName.isNotEmpty ? registration.teamName[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white))
            : null,
      ),
      title: Text(registration.teamName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      trailing: registration.checkedIn
          ? const Icon(Icons.check_circle, color: _kGreen, size: 18)
          : const Icon(Icons.schedule, color: _kTextSecondary, size: 18),
    );
  }
}