import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/wallet_repository.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository();
});

final walletBalanceProvider = StreamProvider.family<num, String>((ref, uid) {
  return ref.watch(walletRepositoryProvider).watchBalance(uid);
});

final walletTransactionsProvider = StreamProvider.family<List<WalletTransaction>, String>((ref, uid) {
  return ref.watch(walletRepositoryProvider).watchTransactions(uid);
});

// --- Deposit action ---

class DepositController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> deposit({required String uid, required num amount, required String method}) async {
    state = const AsyncLoading();
    try {
      await ref.read(walletRepositoryProvider).recordDeposit(uid: uid, amount: amount, method: method);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final depositControllerProvider =
NotifierProvider<DepositController, AsyncValue<void>>(DepositController.new);

// --- Withdraw action ---

class WithdrawController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> withdraw({required String uid, required num amount, required String destination}) async {
    state = const AsyncLoading();
    try {
      await ref.read(walletRepositoryProvider).withdraw(uid: uid, amount: amount, destination: destination);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final withdrawControllerProvider =
NotifierProvider<WithdrawController, AsyncValue<void>>(WithdrawController.new);