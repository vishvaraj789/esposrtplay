import 'package:go_router/go_router.dart';

import 'route_names.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/navigation/main_navigation.dart';
import '../features/splash/presentation/splash_screen.dart';

final appRouter = GoRouter(
  initialLocation: Routes.splash,

  routes: [
    GoRoute(
      path: Routes.splash,
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: Routes.login,
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: Routes.home,
      builder: (_, __) => const MainNavigation(),
    ),
  ],
);