import 'package:flutter/material.dart';

class PlayerProfilesScreen extends StatefulWidget{
  const PlayerProfilesScreen({super.key});

  @override
  State<PlayerProfilesScreen> createState() => _PlayerProfilesScreenState();

}

class _PlayerProfilesScreenState extends State<PlayerProfilesScreen> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Player Profiles"),
        centerTitle: true,
      ),
      body: Center(
          child: const Text("Player Profiles"),
      ),
    );
  }
}