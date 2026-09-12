import 'package:flutter/material.dart';

import '../../../core/widgets/app_textfield.dart';
import '../../../core/widgets/app_button.dart';
import '../provider/profile_provider.dart';

class EditProfileForm extends StatefulWidget {
  final UserProfile profile;
  final void Function({
  required String fullName,
  required String nickname,
  required String freeFireUid,
  String? inGameRole,
  }) onSubmit;
  final bool isSaving;

  const EditProfileForm({
    super.key,
    required this.profile,
    required this.onSubmit,
    this.isSaving = false,
  });

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _nicknameController;
  late final TextEditingController _uidController;
  String? _inGameRole;

  final _roles = const ['Rusher', 'Secondary Rusher', 'Support', 'Nader/IGL'];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _nicknameController = TextEditingController(text: widget.profile.nickname);
    _uidController = TextEditingController(text: widget.profile.freeFireUid);
    _inGameRole = widget.profile.inGameRole;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nicknameController.dispose();
    _uidController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(
      fullName: _fullNameController.text.trim(),
      nickname: _nicknameController.text.trim(),
      freeFireUid: _uidController.text.trim(),
      inGameRole: _inGameRole,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _fullNameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            icon: Icons.person,
            validator: (v) =>
            (v == null || v
                .trim()
                .length < 3) ? 'Full name must be at least 3 characters' : null,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _nicknameController,
            label: 'In-game Nickname',
            hint: 'Your display name',
            icon: Icons.sports_esports,
            validator: (v) =>
            (v == null || v
                .trim()
                .isEmpty) ? 'Nickname is required' : null,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _uidController,
            label: 'Free Fire MAX UID',
            hint: 'Your in-game UID',
            icon: Icons.badge,
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v == null || v
                  .trim()
                  .isEmpty) return 'UID is required';
              if (!RegExp(r'^\d+$').hasMatch(v.trim()))
                return 'UID must contain digits only';
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _inGameRole,
            decoration: InputDecoration(
              labelText: 'In-game Role',
              filled: true,
              fillColor: const Color(0xFF1E293B),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
            ),
            dropdownColor: const Color(0xFF1E293B),
            style: const TextStyle(color: Colors.white),
            items: _roles
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (v) => setState(() => _inGameRole = v),
          ),
          const SizedBox(height: 28),
          AppButton(
            text: 'Save Changes',
            isLoading: widget.isSaving,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}