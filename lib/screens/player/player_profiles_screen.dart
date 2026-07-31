import 'package:flutter/material.dart';

class PlayersProfileScreen extends StatelessWidget{
  const PlayersProfileScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Players Profile"),
        centerTitle: true,
      ),
      body: const Text("Players profile Screen"),
    );
  }
}