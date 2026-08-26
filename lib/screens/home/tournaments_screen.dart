import 'package:flutter/material.dart';

/// All upcoming, live, and completed tournaments.
class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournaments'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Live'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _TournamentListPlaceholder(status: 'Upcoming'),
          _TournamentListPlaceholder(status: 'Live'),
          _TournamentListPlaceholder(status: 'Completed'),
        ],
      ),
    );
  }
}

class _TournamentListPlaceholder extends StatelessWidget {
  final String status;

  const _TournamentListPlaceholder({required this.status});

  @override
  Widget build(BuildContext context) {
    // TODO: replace with a real list fetched from your backend, filtered by status.
    return Center(
      child: Text('No $status tournaments yet'),
    );
  }
}