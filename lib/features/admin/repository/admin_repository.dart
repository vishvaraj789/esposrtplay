import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/admin_stats_model.dart';
import '../models/announcement_model.dart';

class AdminRepository {
  final FirebaseFirestore _firestore;

  AdminRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Checks the signed-in user's `role` field on users/{uid}.
  Stream<bool> watchIsAdmin(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map(
          (doc) => doc.data()?['role'] == 'admin',
    );
  }

  /// One-shot aggregation for the dashboard header. Runs a handful of
  /// count/sum queries in parallel rather than downloading full collections.
  Future<AdminStats> fetchDashboardStats() async {
    final startOfDay = DateTime.now().copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);

    final results = await Future.wait([
      _firestore.collection('tournaments').count().get(),
      _firestore.collection('teams').count().get(),
      _firestore
          .collection('matches')
          .where('scheduledAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('scheduledAt', isLessThan: Timestamp.fromDate(startOfDay.add(const Duration(days: 1))))
          .count()
          .get(),
      _firestore.collection('tournaments').get(),
    ]);

    final tournamentCount = (results[0] as AggregateQuerySnapshot).count ?? 0;
    final teamCount = (results[1] as AggregateQuerySnapshot).count ?? 0;
    final matchesTodayCount = (results[2] as AggregateQuerySnapshot).count ?? 0;
    final tournamentDocs = (results[3] as QuerySnapshot<Map<String, dynamic>>).docs;

    final prizePool = tournamentDocs.fold<double>(
      0,
          (sum, doc) => sum + ((doc.data()['prizePool'] ?? 0) as num).toDouble(),
    );

    return AdminStats(
      totalTournaments: tournamentCount,
      totalTeams: teamCount,
      matchesToday: matchesTodayCount,
      totalPrizePool: prizePool,
    );
  }

  // --- Announcements ---

  Stream<List<AnnouncementModel>> watchAnnouncements() {
    return _firestore
        .collection('announcements')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => AnnouncementModel.fromFirestore(d.id, d.data())).toList());
  }

  Future<void> createAnnouncement({
    required String title,
    required String message,
    required String createdBy,
  }) {
    return _firestore.collection('announcements').add({
      'title': title,
      'message': message,
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteAnnouncement(String id) {
    return _firestore.collection('announcements').doc(id).delete();
  }
}