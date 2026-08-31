import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../service/user_service.dart';

/// Top app bar used on Home (and reusable elsewhere): shows the signed-in
/// user's avatar, a "Hi, {nickname}" greeting, their wallet/coin balance,
/// a notifications icon, and a settings shortcut.
///
/// Pulls live data from Firestore via UserService.watchUserProfile, so the
/// greeting/balance update automatically without a manual refresh (e.g.
/// right after a tournament payout changes their coins).
class TopAppBar extends StatelessWidget {
  /// Called when the notifications icon is tapped.
  final VoidCallback? onNotificationsTap;

  /// Called when the settings icon is tapped.
  final VoidCallback? onSettingsTap;

  /// Called when the avatar or greeting is tapped (e.g. navigate to Profile).
  final VoidCallback? onProfileTap;

  /// Optional badge count shown on the notifications icon. Null or 0 hides it.
  final int unreadNotifications;

  const TopAppBar({
    super.key,
    this.onNotificationsTap,
    this.onSettingsTap,
    this.onProfileTap,
    this.unreadNotifications = 0,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6A3D), Color(0xFFFF3D5A)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: uid == null
            ? const SizedBox.shrink()
            : StreamBuilder<Map<String, dynamic>?>(
          stream: UserService.instance.watchUserProfile(uid),
          builder: (context, snapshot) {
            final profile = snapshot.data;
            final nickname = profile?['nickname'] as String? ?? 'Player';
            final photoUrl = profile?['photoUrl'] as String?;
            final walletBalance =
                (profile?['walletBalance'] as num?)?.toInt() ?? 0;

            return Row(
              children: [
                // Avatar + greeting
                Expanded(
                  child: InkWell(
                    onTap: onProfileTap,
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          backgroundImage:
                          photoUrl != null ? NetworkImage(photoUrl) : null,
                          child: photoUrl == null
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Welcome back",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "Hi, $nickname",
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Wallet / coin balance
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: Colors.amberAccent,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        walletBalance.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),

                // Notifications
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: onNotificationsTap,
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                      ),
                    ),
                    if (unreadNotifications > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadNotifications > 9
                                ? '9+'
                                : unreadNotifications.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                // Settings
                IconButton(
                  onPressed: onSettingsTap,
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: Colors.white,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}