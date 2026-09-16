import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../routes/route_names.dart';
import '../../auth/provider/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    // Keep the splash on screen for a minimum, visible duration...
    final minDelay = Future.delayed(const Duration(seconds: 2));

    // ...while resolving auth state in parallel, with a timeout so a
    // slow/broken network can't leave the user stuck here forever.
    User? user;
    try {
      user = await ref
          .read(authStateProvider.future)
          .timeout(const Duration(seconds: 8));
    } catch (e) {
      debugPrint('[splash] auth check failed: $e');
      user = null; // fail safe -> send to login rather than hang
    }

    await minDelay;
    if (!mounted) return;

    context.go(user != null ? Routes.home : Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_esports, size: 72, color: AppColors.secondary),
            const SizedBox(height: 16),
            const Text(
              'EsportPlay',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: AppColors.secondary),
          ],
        ),
      ),
    );
  }
}