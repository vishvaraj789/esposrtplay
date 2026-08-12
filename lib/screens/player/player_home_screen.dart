import 'package:flutter/material.dart';

class PlayerHomeScreen  extends StatefulWidget{
  const PlayerHomeScreen({super.key});
  @override
  State<PlayerHomeScreen> createState() => _PlayerHomeScreenState();
}

class _PlayerHomeScreenState extends State<PlayerHomeScreen>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Player Home"),
        centerTitle: true,
      ),
    );
  }
}