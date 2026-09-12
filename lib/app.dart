import 'package:flutter/material.dart';

import 'routes/app_router.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';

class EsportPlayApp extends StatelessWidget {
  const EsportPlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "EsportPlay",
      debugShowCheckedModeBanner: false,

      routerConfig: appRouter,

      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}