import 'package:flutter/material.dart';

class MemberDetailsScreen extends StatefulWidget{
  const MemberDetailsScreen({super.key});

  @override
  State<MemberDetailsScreen> createState() => _MemberDetailsScreenState();
}

class _MemberDetailsScreenState extends State<MemberDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Member Details"),
        centerTitle: true,
      )
    );
  }
}