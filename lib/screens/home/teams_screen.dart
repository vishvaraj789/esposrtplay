import 'package:flutter/material.dart';

/// Create a team, join a team, or manage squad members.
class TeamsScreen extends StatelessWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teams'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: navigate to create-team flow.
                },
                icon: const Icon(Icons.add),
                label: const Text('Create a Team'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: navigate to join-team flow (e.g. via invite code).
                },
                icon: const Icon(Icons.login),
                label: const Text('Join a Team'),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Your Squad',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            // TODO: replace with real squad member list.
            const Expanded(
              child: Center(child: Text('You are not on a team yet')),
            ),
          ],
        ),
      ),
    );
  }
}