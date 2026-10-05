import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../tournaments/model/tournament_model.dart';

/// Admin-side tournament operations. Unlike the player-facing
/// TournamentRepository, this sees drafts too and can edit/delete anything.
class TournamentAdminRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  TournamentAdminRepository({FirebaseFirestore? firestore, FirebaseStorage? storage})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance {
    // Default is 10 minutes of silent retries; fail fast instead.
    _storage.setMaxUploadRetryTime(const Duration(seconds: 30));
  }

  CollectionReference<Map<String, dynamic>> get _tournaments => _firestore.collection('tournaments');

  Stream<List<Tournament>> watchAllTournaments() {
    return _tournaments
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Tournament.fromFirestore(d.id, d.data())).toList());
  }

  Future<String> _uploadBanner(String tournamentId, File file) async {
    final ref = _storage.ref('tournament_banners/$tournamentId.jpg');
    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }

  Future<void> _deleteBannerQuietly(String tournamentId) async {
    try {
      await _storage.ref('tournament_banners/$tournamentId.jpg').delete();
    } catch (_) {
      // No banner (or already gone): nothing to clean up.
    }
  }

  /// Uploads the banner and attaches its URL. Runs after the tournament is
  /// already saved, so a slow upload never blocks the form.
  Future<void> _attachBanner(String id, File file) async {
    try {
      final url = await _uploadBanner(id, file);
      await _tournaments.doc(id).update({'bannerUrl': url});
    } catch (e) {
      debugPrint('[tournament] banner upload failed for $id: $e');
    }
  }

  /// Saves the tournament first (fast), then uploads the banner in the background.
  Future<String> createTournament(Map<String, dynamic> data, {File? banner}) async {
    final doc = _tournaments.doc();
    await doc.set({
      ...data,
      'currentParticipants': 0,
      'prizeBreakdown': <String, dynamic>{},
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }).timeout(const Duration(seconds: 15));

    if (banner != null) unawaited(_attachBanner(doc.id, banner));
    return doc.id;
  }

  Future<void> updateTournament(
      String id,
      Map<String, dynamic> updates, {
        File? banner,
        bool removeBanner = false,
      }) async {
    final payload = <String, dynamic>{...updates, 'updatedAt': FieldValue.serverTimestamp()};
    if (removeBanner && banner == null) payload['bannerUrl'] = FieldValue.delete();

    await _tournaments.doc(id).update(payload).timeout(const Duration(seconds: 15));

    if (banner != null) {
      unawaited(_attachBanner(id, banner));
    } else if (removeBanner) {
      unawaited(_deleteBannerQuietly(id));
    }
  }

  /// Deletes the tournament, its registrations and its banner.
  /// (Firestore doesn't cascade deletes into subcollections on its own.)
  Future<void> deleteTournament(String id) async {
    final ref = _tournaments.doc(id);

    final regs = await ref.collection('registrations').get();
    for (var i = 0; i < regs.docs.length; i += 400) {
      final batch = _firestore.batch();
      for (final d in regs.docs.skip(i).take(400)) {
        batch.delete(d.reference);
      }
      await batch.commit();
    }

    await ref.delete();
    await _deleteBannerQuietly(id);
  }

  Future<void> setStatus(String id, TournamentStatus status) {
    return _tournaments.doc(id).update({'status': status.name, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> setPublished(String id, bool published) {
    return _tournaments.doc(id).update({'isPublished': published, 'updatedAt': FieldValue.serverTimestamp()});
  }
}