import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('[main] Firebase initialized successfully');

  FirebaseAuth.instance.authStateChanges().listen((user) {
    debugPrint('[test] authStateChanges emitted: ${user?.uid}');
  });

  runApp(
    const ProviderScope(
      child: EsportPlayApp(),
    ),
  );
}