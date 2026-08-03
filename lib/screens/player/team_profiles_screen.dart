import 'package:flutter/material.dart';

class TeamProfilesScreen extends StatefulWidget{
  const TeamProfilesScreen({super.key});
  
  @override
  State<TeamProfilesScreen> createState() => _TeamProfilesScreenState();
}

class _TeamProfilesScreenState extends State<TeamProfilesScreen>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("team_profiles"),
      ),
    );
  }
}