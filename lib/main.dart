import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'screens/home/main_navigation.dart';
import 'screens/auth/login_screen.dart';
import 'screens/service/user_service.dart';
import 'screens/user_form.dart'; // your registration form (UserForm widget)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EsportPlay',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const AuthGate(),
      routes: <String, WidgetBuilder>{
        '/login': (BuildContext context) => const LoginScreen(),
        '/register': (BuildContext context) => const UserForm(),
        '/home': (BuildContext context) => const MainNavigation(),
      },
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
        // Still checking whether a session exists.
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
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
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (profileSnapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text('Error checking profile: ${profileSnapshot.error}'),
                ),
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