import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';
import 'screens/home/main_navigation.dart';
import 'screens/auth/login_screen.dart';
import 'screens/service/user_service.dart';
import 'screens/user_form.dart'; // your registration form (UserForm widget)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Guard Firebase init so a config/network problem shows a readable
  // error screen instead of a raw crash before anything renders.
  Object? initError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // google_sign_in v7+ requires this exactly once before authenticate()
    // or signOut() are called anywhere in the app. Skipping this means
    // the Google account picker silently never appears.
    await GoogleSignIn.instance.initialize();
  } catch (e) {
    initError = e;
  }

  runApp(initError == null
      ? const MyApp()
      : _InitErrorApp(error: initError));
}

/// Shown only if Firebase fails to initialize (bad config, no network
/// on first launch, etc.) — better than a blank screen or a stack trace.
class _InitErrorApp extends StatelessWidget {
  final Object error;

  const _InitErrorApp({required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  "Couldn't start EsportPlay",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Matches the brand gradient used on Login/Register (#FF6A3D -> #FF3D5A)
  // so buttons, links, and highlights are consistent app-wide instead of
  // defaulting to Material's generic deepOrange seed.
  static const _brandColor = Color(0xFFFF3D5A);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EsportPlay',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _brandColor),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
      ),
      home: const AuthGate(),
      routes: <String, WidgetBuilder>{
        '/login': (BuildContext context) => const LoginScreen(),
        '/register': (BuildContext context) => const UserForm(),
        '/home': (BuildContext context) => const MainNavigation(),
      },
      // Avoids a raw "no route found" crash if something navigates to
      // an unregistered route name by mistake.
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: Center(child: Text("Page not found")),
        ),
      ),
    );
  }
}

/// Reactively decides which screen to show based on Firebase auth state:
/// - Not signed in            -> LoginScreen
/// - Signed in, no profile    -> UserForm (complete profile)
/// - Signed in, has profile   -> MainNavigation
///
/// This means a returning user who already filled out UserForm skips
/// straight into the app instead of seeing that form again.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        if (authSnapshot.hasError) {
          return _ErrorScreen(message: 'Auth error: ${authSnapshot.error}');
        }

        final user = authSnapshot.data;

        // Not signed in at all.
        if (user == null) {
          return const LoginScreen();
        }

        // Signed in — now check whether a Firestore profile already exists.
        return FutureBuilder<bool>(
          future: UserService.instance.hasProfile(user.uid),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScreen();
            }

            if (profileSnapshot.hasError) {
              return _ErrorScreen(
                message: 'Error checking profile: ${profileSnapshot.error}',
              );
            }

            final hasProfile = profileSnapshot.data ?? false;

            if (hasProfile) {
              return const MainNavigation();
            }

            // Signed in but profile not completed yet.
            return const UserForm();
          },
        );
      },
    );
  }
}

/// Shared loading state so AuthGate doesn't repeat the same
/// Scaffold + CircularProgressIndicator in two places.
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

/// Shared error state for AuthGate's two failure points (auth stream
/// error, or the Firestore profile-check failing).
class _ErrorScreen extends StatelessWidget {
  final String message;

  const _ErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}