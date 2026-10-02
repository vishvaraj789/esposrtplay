import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/user_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/route_names.dart';

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

  String? _selectedInGameRole;
  bool _isLoading = false;

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
      await UserService.instance.createUserProfile(
        uid: user.uid,
        fullName: _fullNameController.text.trim(),
        email: user.email ?? '',
        freeFireUid: _uidController.text.trim(),
        nickname: _nicknameController.text.trim(),
        inGameRole: _selectedInGameRole!,
        role: 'player'
      );

      if (!mounted) return;
      context.go(Routes.home);
    } on StateError {
      // Profile already exists for this account — don't treat this as a
      // failure, just move the user forward instead of overwriting data.
      if (!mounted) return;
      context.go(Routes.home);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _fieldDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey[500]),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF7F8FC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Branded header — now on AppColors palette (purple -> cyan),
              // matching the rebuilt Login/Register screens.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_pin_circle,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "Complete Your Profile",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Just a few details before you jump in.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Form card, overlapping the header — matches Login/Register
              Transform.translate(
                offset: const Offset(0, -28),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Your details",
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "Step 2 of 2",
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _fullNameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: _fieldDecoration(
                            label: 'Full Name',
                            hint: 'Enter your full name',
                            icon: Icons.person,
                          ),
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
                          decoration: _fieldDecoration(
                            label: 'Free Fire MAX UID',
                            hint: 'Your in-game UID',
                            icon: Icons.badge,
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
                          decoration: _fieldDecoration(
                            label: 'In-game Nickname',
                            hint: 'Your display name',
                            icon: Icons.sports_esports,
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
                          initialValue: _selectedInGameRole,
                          decoration: _fieldDecoration(
                            label: 'In-game Role',
                            hint: 'Select your role',
                            icon: Icons.sports_kabaddi,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          items: _inGameRoles
                              .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(role),
                          ))
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
                        const SizedBox(height: 28),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Save & Continue',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}