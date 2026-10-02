import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_textfield.dart';
import '../provider/admin_provider.dart';
import '../widgets/announcement_card.dart';

class AdminAnnouncementsScreen extends ConsumerStatefulWidget {
  const AdminAnnouncementsScreen({super.key});
  @override
  ConsumerState<AdminAnnouncementsScreen> createState() => _AdminAnnouncementsScreenState();
}

class _AdminAnnouncementsScreenState extends ConsumerState<AdminAnnouncementsScreen> {
  final _title = TextEditingController();
  final _message = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  void dispose() { _title.dispose(); _message.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final announcements = ref.watch(announcementsProvider);
    final busy = ref.watch(createAnnouncementControllerProvider).isLoading;
    return Scaffold(backgroundColor: AppColors.backgroundDark, appBar: AppBar(backgroundColor: AppColors.backgroundDark, title: const Text('Announcements')), body: ListView(padding: const EdgeInsets.all(16), children: [
      Form(key: _formKey, child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF171821), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2C38))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Post announcement', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)), const SizedBox(height: 14),
        AppTextField(controller: _title, label: 'Title', validator: _required), const SizedBox(height: 12),
        AppTextField(controller: _message, label: 'Message', maxLines: 4, validator: _required), const SizedBox(height: 16),
        AppButton(text: 'Publish announcement', icon: Icons.campaign_outlined, isLoading: busy, onPressed: busy ? null : _create),
      ]))), const SizedBox(height: 24),
      const Text('Published', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)), const SizedBox(height: 10),
      announcements.when(loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())), error: (error, _) => Text('Could not load announcements: $error', style: const TextStyle(color: Colors.redAccent)), data: (items) => items.isEmpty ? const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No announcements yet', style: TextStyle(color: Colors.white54)))) : Column(children: items.map((item) => AnnouncementCard(announcement: item, onDelete: () => _delete(item.id))).toList())),
    ]));
  }
  String? _required(String? value) => value == null || value.trim().isEmpty ? 'Required' : null;
  Future<void> _create() async { if (!_formKey.currentState!.validate()) return; final uid = FirebaseAuth.instance.currentUser?.uid; if (uid == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign in again to post an announcement'))); return; } final ok = await ref.read(createAnnouncementControllerProvider.notifier).create(title: _title.text.trim(), message: _message.text.trim(), createdBy: uid); if (mounted && ok) { _title.clear(); _message.clear(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Announcement published'))); } if (mounted && !ok) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not publish announcement'))); }
  Future<void> _delete(String id) async { final ok = await ref.read(adminRepositoryProvider).deleteAnnouncement(id).then((_) => true).catchError((_) => false); if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Announcement deleted' : 'Could not delete announcement'))); }
}
