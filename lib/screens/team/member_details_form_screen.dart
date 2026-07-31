import 'package:flutter/material.dart';

class MemberDetailsScreen extends StatefulWidget {
  final int playerCount;

  const MemberDetailsScreen({
    super.key,
    required this.playerCount,
  });

  @override
  State<MemberDetailsScreen> createState() => _MemberDetailsScreenState();
}

class _MemberDetailsScreenState extends State<MemberDetailsScreen> {
  late List<TextEditingController> playerNameControllers;
  late List<TextEditingController> playerUidControllers;
  late List<String> selectedRoles;

  final List<String> roles = [
    "IGL",
    "Rusher",
    "Sniper",
    "Support",
    "Entry Fragger",
  ];

  @override
  void initState() {
    super.initState();

    playerNameControllers = List.generate(
      widget.playerCount,
          (_) => TextEditingController(),
    );

    playerUidControllers = List.generate(
      widget.playerCount,
          (_) => TextEditingController(),
    );

    selectedRoles = List.generate(
      widget.playerCount,
          (_) => roles.first,
    );
  }

  @override
  void dispose() {
    for (var controller in playerNameControllers) {
      controller.dispose();
    }

    for (var controller in playerUidControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Member Details"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...List.generate(widget.playerCount, (index) {
            return Card(
              color: Colors.white10,
              margin: const EdgeInsets.only(bottom: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      "Player ${index + 1}",
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.orange,
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: playerNameControllers[index],
                      decoration: const InputDecoration(
                        labelText: "Player Name",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller: playerUidControllers[index],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Player UID",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge),
                      ),
                    ),

                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      value: selectedRoles[index],
                      decoration: const InputDecoration(
                        labelText: "Game Role",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.sports_esports),
                      ),
                      items: roles.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRoles[index] = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          }),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                for (int i = 0; i < widget.playerCount; i++) {
                  debugPrint(
                    "Player ${i + 1}: "
                        "${playerNameControllers[i].text}, "
                        "${playerUidControllers[i].text}, "
                        "${selectedRoles[i]}",
                  );
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Members Saved Successfully"),
                  ),
                );
              },
              child: const Text(
                "Submit",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}