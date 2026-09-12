import 'package:cloud_firestore/cloud_firestore.dart';

// --- Data models ---

class TeamMember {
  final String uid;
  final String name;
  final String role;
  final bool isCaptain;
  final DateTime joinedAt;

  const TeamMember({
    required this.uid,
    required this.name,
    required this.role,
    this.isCaptain = false,
    required this.joinedAt,
  });

  factory TeamMember.fromFirestore(String uid, Map<String, dynamic> data) {
    return TeamMember(
      uid: uid,
      name: data['name'] ?? 'Unknown',
      role: data['role'] ?? 'Player',
      isCaptain: data['isCaptain'] ?? false,
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class TeamModel {
  final String id;
  final String name;
  final String tag;
  final String? logoUrl;
  final String inviteCode;
  final String captainUid;
  final List<String> memberUids;
  final int maxMembers;
  final int matches;
  final int wins;
  final int rank;

  const TeamModel({
    required this.id,
    required this.name,
    required this.tag,
    this.logoUrl,
    required this.inviteCode,
    required this.captainUid,
    required this.memberUids,
    this.maxMembers = 4,
    this.matches = 0,
    this.wins = 0,
    this.rank = 0,
  });

  double get winRate => matches == 0 ? 0 : wins / matches;
  bool get isFull => memberUids.length >= maxMembers;

  factory TeamModel.fromFirestore(String id, Map<String, dynamic> data) {
    return TeamModel(
      id: id,
      name: data['name'] ?? '',
      tag: data['tag'] ?? '',
      logoUrl: data['logoUrl'],
      inviteCode: data['inviteCode'] ?? '',
      captainUid: data['captainUid'] ?? '',
      memberUids: List<String>.from(data['memberUids'] ?? []),
      maxMembers: data['maxMembers'] ?? 4,
      matches: data['matches'] ?? 0,
      wins: data['wins'] ?? 0,
      rank: data['rank'] ?? 0,
    );
  }
}

class TeamRepository {
  final FirebaseFirestore _firestore;

  TeamRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _teams => _firestore.collection('teams');

  /// A user is on at most one team at a time (matches teams_screen.dart's
  /// single hasTeam/empty-state toggle). Returns null if they're on none.
  Stream<TeamModel?> watchUserTeam(String uid) {
    return _teams
        .where('memberUids', arrayContains: uid)
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isEmpty ? null : TeamModel.fromFirestore(snap.docs.first.id, snap.docs.first.data()));
  }

  Stream<TeamModel?> watchTeam(String teamId) {
    return _teams.doc(teamId).snapshots().map(
          (doc) => doc.exists ? TeamModel.fromFirestore(doc.id, doc.data()!) : null,
    );
  }

  Stream<List<TeamMember>> watchMembers(String teamId) {
    return _teams
        .doc(teamId)
        .collection('members')
        .orderBy('joinedAt')
        .snapshots()
        .map((snap) => snap.docs.map((d) => TeamMember.fromFirestore(d.id, d.data())).toList());
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no O/0/I/1 ambiguity
    final rand = DateTime.now().millisecondsSinceEpoch;
    return List.generate(6, (i) => chars[(rand ~/ (i + 1)) % chars.length]).join();
  }

  Future<String> createTeam({
    required String name,
    required String tag,
    required String captainUid,
    required String captainName,
    required String captainRole,
    String? logoUrl,
  }) async {
    final inviteCode = _generateInviteCode();
    final teamRef = _teams.doc();

    await _firestore.runTransaction((txn) async {
      txn.set(teamRef, {
        'name': name,
        'tag': tag,
        'logoUrl': logoUrl,
        'inviteCode': inviteCode,
        'captainUid': captainUid,
        'memberUids': [captainUid],
        'maxMembers': 4,
        'matches': 0,
        'wins': 0,
        'rank': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
      txn.set(teamRef.collection('members').doc(captainUid), {
        'name': captainName,
        'role': captainRole,
        'isCaptain': true,
        'joinedAt': FieldValue.serverTimestamp(),
      });
    });

    return teamRef.id;
  }

  Future<String> joinByInviteCode({
    required String inviteCode,
    required String uid,
    required String name,
    required String role,
  }) async {
    final matches = await _teams.where('inviteCode', isEqualTo: inviteCode).limit(1).get();
    if (matches.docs.isEmpty) throw Exception('Invalid invite code');

    final teamRef = matches.docs.first.reference;

    return _firestore.runTransaction<String>((txn) async {
      final snap = await txn.get(teamRef);
      final data = snap.data();
      if (data == null) throw Exception('Team not found');

      final memberUids = List<String>.from(data['memberUids'] ?? []);
      final maxMembers = data['maxMembers'] ?? 4;
      if (memberUids.contains(uid)) throw Exception('Already on this team');
      if (memberUids.length >= maxMembers) throw Exception('Team is full');

      txn.update(teamRef, {
        'memberUids': FieldValue.arrayUnion([uid]),
      });
      txn.set(teamRef.collection('members').doc(uid), {
        'name': name,
        'role': role,
        'isCaptain': false,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      return teamRef.id;
    });
  }

  Future<void> leaveTeam({required String teamId, required String uid}) async {
    final teamRef = _teams.doc(teamId);
    await _firestore.runTransaction((txn) async {
      final snap = await txn.get(teamRef);
      final data = snap.data();
      if (data == null) return;
      if (data['captainUid'] == uid) {
        throw Exception('Captain must transfer captaincy before leaving');
      }
      txn.update(teamRef, {
        'memberUids': FieldValue.arrayRemove([uid]),
      });
      txn.delete(teamRef.collection('members').doc(uid));
    });
  }

  Future<void> removeMember({required String teamId, required String uid}) async {
    final teamRef = _teams.doc(teamId);
    await teamRef.update({
      'memberUids': FieldValue.arrayRemove([uid]),
    });
    await teamRef.collection('members').doc(uid).delete();
  }

  Future<void> transferCaptain({
    required String teamId,
    required String newCaptainUid,
    required String oldCaptainUid,
  }) async {
    final teamRef = _teams.doc(teamId);
    final membersRef = teamRef.collection('members');

    await _firestore.runTransaction((txn) async {
      txn.update(teamRef, {'captainUid': newCaptainUid});
      txn.update(membersRef.doc(newCaptainUid), {'isCaptain': true});
      txn.update(membersRef.doc(oldCaptainUid), {'isCaptain': false});
    });
  }
}