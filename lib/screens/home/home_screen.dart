import 'package:flutter/material.dart';

/// Dashboard: tournaments overview, quick actions, announcements.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EsportPlay'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Announcements',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Welcome to EsportPlay! Check out live tournaments below.'),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: navigate to tournament join flow.
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Join Tournament'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: navigate to create-team flow.
                  },
                  icon: const Icon(Icons.group_add),
                  label: const Text('Create Team'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Upcoming Tournaments',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          // TODO: replace with a real list of tournaments from your backend.
          const ListTile(
            leading: Icon(Icons.emoji_events),
            title: Text('Free Fire MAX Cup — Aug 30'),
            subtitle: Text('Registration open'),
          ),
        ],
      ),
    );
  }
}