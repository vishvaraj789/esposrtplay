import 'dart:async';

import 'package:flutter/foundation.dart';

/// Bridges a Stream (e.g. Firebase auth state) into a Listenable that
/// GoRouter's `refreshListenable` can use to re-run `redirect` whenever
/// the stream emits — without recreating the GoRouter instance itself
/// (which would reset the navigation stack).
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}