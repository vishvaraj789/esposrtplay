import 'package:flutter/material.dart';

import '../core/widgets/app_top_bar.dart';
import '../core/widgets/empty_widget.dart';

/// Temporary stand-in for screens that are routed but not built yet.
/// Replace each usage in app_router.dart with the real screen as it lands,
/// then delete this file once nothing references it.
class RoutePlaceholderScreen extends StatelessWidget {
  final String title;
  final String? details;

  const RoutePlaceholderScreen({super.key, required this.title, this.details});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(title: title),
      body: EmptyWidget(
        icon: Icons.construction_outlined,
        message: details == null ? '$title - coming soon' : '$title - coming soon\n$details',
      ),
    );
  }
}