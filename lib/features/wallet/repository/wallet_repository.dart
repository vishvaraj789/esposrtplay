import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { deposit, withdrawal, entryFee, prizePayout }

TransactionType _typeFromString(String s) =>
    TransactionType.values.firstWhere((e) => e.name == s, orElse: () => TransactionType.deposit);

class WalletTransaction {
  final String id;
  final TransactionType type;
  final num amount;
  final String description;
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
  });

  bool get isCredit => type == TransactionType.deposit || type == TransactionType.prizePayout;

  factory WalletTransaction.fromFirestore(String id, Map<String, dynamic> data) {
    return WalletTransaction(
      id: id,
      type: _typeFromString(data['type'] ?? 'deposit'),
      amount: data['amount'] ?? 0,
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class WalletRepository {
  final FirebaseFirestore _firestore;

  WalletRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userRef(String uid) => _firestore.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _transactionsRef(String uid) =>
      _userRef(uid).collection('transactions');

  Stream<num> watchBalance(String uid) {
    return _userRef(uid).snapshots().map((doc) => doc.data()?['walletBalance'] ?? 0);
  }

  Stream<List<WalletTransaction>> watchTransactions(String uid, {int limit = 50}) {
    return _transactionsRef(uid)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => WalletTransaction.fromFirestore(d.id, d.data())).toList());
  }

  /// Records a completed deposit and credits the balance. Call this AFTER
  /// your payment gateway (UPI/card) confirms success — this method does
  /// not itself talk to any payment provider.
  ///
  /// TODO: wire up an actual gateway (e.g. razorpay_flutter or Cashfree)
  /// before going live. Right now nothing in pubspec.yaml handles payment
  /// collection, so this only updates Firestore as if payment succeeded.
  Future<void> recordDeposit({
    required String uid,
    required num amount,
    required String method,
  }) async {
    if (amount <= 0) throw Exception('Amount must be greater than zero');

    final userRef = _userRef(uid);
    final txnRef = _transactionsRef(uid).doc();

    await _firestore.runTransaction((txn) async {
      txn.update(userRef, {'walletBalance': FieldValue.increment(amount)});
      txn.set(txnRef, {
        'type': TransactionType.deposit.name,
        'amount': amount,
        'description': 'Added via $method',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Instant withdrawal — deducts immediately, no admin approval step.
  Future<void> withdraw({
    required String uid,
    required num amount,
    required String destination, // e.g. UPI ID or bank details string
  }) async {
    if (amount <= 0) throw Exception('Amount must be greater than zero');

    final userRef = _userRef(uid);
    final txnRef = _transactionsRef(uid).doc();

    await _firestore.runTransaction((txn) async {
      final snap = await txn.get(userRef);
      final balance = (snap.data()?['walletBalance'] ?? 0) as num;
      if (balance < amount) throw Exception('Insufficient balance');

      txn.update(userRef, {'walletBalance': FieldValue.increment(-amount)});
      txn.set(txnRef, {
        'type': TransactionType.withdrawal.name,
        'amount': amount,
        'description': 'Withdrawn to $destination',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}