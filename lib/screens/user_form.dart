import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/service/user_service.dart';

/// Collects the extra profile fields not covered by Firebase Auth.
/// Expects the user to already be signed in (e.g. right after the
/// LoginScreen creates their Firebase Auth account) — it reads their
/// uid/email from FirebaseAuth.instance.currentUser and saves the rest
/// to Firestore.
class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _uidController = TextEditingController();
  final _nicknameController = TextEditingController();

  String? _selectedRole;
  String? _selectedInGameRole;
  bool _isLoading = false;

  final List<String> _roles = [
    'Player',
    'Captain',
    'Organizer',
    'Spectator',
  ];

  final List<String> _inGameRoles = [
    'Rusher',
    'Secondary Rusher',
    'Support',
    'Nader/IGL',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _uidController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in to complete your profile.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Save the profile fields to Firestore, keyed by the signed-in user's UID.
      await UserService.instance.createUserProfile(
        uid: user.uid,
        fullName: _fullNameController.text.trim(),
        email: user.email ?? '',
        freeFireUid: _uidController.text.trim(),
        nickname: _nicknameController.text.trim(),
        role: _selectedRole!,
        inGameRole: _selectedInGameRole!,
      );

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } on StateError {
      // Profile already exists for this account — don't treat this as a
      // failure, just move the user forward instead of overwriting data.
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Your Profile"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Full name is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Full name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _uidController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Free Fire MAX UID',
                  hintText: 'Your in-game UID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Free Fire MAX UID is required';
                  }
                  if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
                    return 'UID must contain digits only';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: 'In-game Nickname',
                  hintText: 'Your display name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sports_esports),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'In-game nickname is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group),
                ),
                items: _roles
                    .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedRole = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a role';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _selectedInGameRole,
                decoration: const InputDecoration(
                  labelText: 'In-game Role',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sports_kabaddi),
                ),
                items: _inGameRoles
                    .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedInGameRole = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an in-game role';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Save & Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}