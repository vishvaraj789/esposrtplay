import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/admin_stats_model.dart';
import '../models/announcement_model.dart';

class AdminRepository {
  final FirebaseFirestore _firestore;

  AdminRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Dashboard counters. Uses server-side count() queries so no collection
  /// is downloaded; all run in parallel.
  Future<AdminStats> fetchDashboardStats() async {
    final tournaments = _firestore.collection('tournaments');

    final results = await Future.wait([
      _firestore.collection('users').count().get(),
      _firestore.collection('teams').count().get(),
      tournaments.count().get(),
      tournaments.where('status', isEqualTo: 'live').count().get(),
      tournaments.where('status', isEqualTo: 'upcoming').count().get(),
      tournaments.where('status', isEqualTo: 'completed').count().get(),
    ]);

    int c(int i) => results[i].count ?? 0;

    return AdminStats(
      totalPlayers: c(0),
      totalTeams: c(1),
      totalTournaments: c(2),
      liveTournaments: c(3),
      upcomingTournaments: c(4),
      completedTournaments: c(5),
    );
  }

  /// Newest players, teams and tournaments merged into one timeline.
  /// Documents without a `createdAt` timestamp are skipped.
  Future<List<AdminActivity>> fetchRecentActivity({int limit = 8}) async {
    Future<QuerySnapshot<Map<String, dynamic>>> latest(String collection) => _firestore
        .collection(collection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    final snaps = await Future.wait([
      latest('users'),
      latest('teams'),
      latest('tournaments'),
    ]);

    DateTime? time(Map<String, dynamic> data) {
      final v = data['createdAt'];
      return v is Timestamp ? v.toDate() : null;
    }

    final items = <AdminActivity>[];

    for (final doc in snaps[0].docs) {
      final data = doc.data();
      final t = time(data);
      if (t == null) continue;
      items.add(AdminActivity(
        type: AdminActivityType.player,
        title: 'New player registered',
        subtitle: (data['nickname'] ?? 'Unknown player').toString(),
        time: t,
      ));
    }
    for (final doc in snaps[1].docs) {
      final data = doc.data();
      final t = time(data);
      if (t == null) continue;
      items.add(AdminActivity(
        type: AdminActivityType.team,
        title: 'Team created',
        subtitle: (data['name'] ?? 'Unnamed team').toString(),
        time: t,
      ));
    }
    for (final doc in snaps[2].docs) {
      final data = doc.data();
      final t = time(data);
      if (t == null) continue;
      items.add(AdminActivity(
        type: AdminActivityType.tournament,
        title: 'Tournament created',
        subtitle: (data['name'] ?? 'Unnamed tournament').toString(),
        time: t,
      ));
    }

    items.sort((a, b) => b.time.compareTo(a.time));
    return items.take(limit).toList();
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