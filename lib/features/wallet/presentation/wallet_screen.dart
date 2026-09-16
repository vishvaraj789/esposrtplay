import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/provider/auth_provider.dart';
import '../provider/wallet_provider.dart';
import '../repository/wallet_repository.dart';
import 'transaction_screen.dart';
import 'withdraw_screen.dart';

const _kBg = Color(0xFF0F172A);
const _kCard = Color(0xFF171821);
const _kHairline = Color(0xFF2A2C38);
const _kGold = Color(0xFFFFC24B);
const _kGreen = Color(0xFF3DDC84);
const _kTextSecondary = Color(0xFF9CA0AF);
const _kBrandGradient = LinearGradient(
  colors: [Color(0xFFFF6A3D), Color(0xFFFF3D5A)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  void _showAddMoneySheet(BuildContext context, WidgetRef ref, String uid) {
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: _kCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: 20 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add Money', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter amount',
                  hintStyle: const TextStyle(color: _kTextSecondary),
                  filled: true,
                  fillColor: _kBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Payment gateway not yet integrated — this simulates a successful deposit.',
                style: TextStyle(color: _kTextSecondary, fontSize: 11),
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, _) {
                  final state = ref.watch(depositControllerProvider);
                  return SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF3D5A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: state.isLoading
                          ? null
                          : () async {
                        final amount = num.tryParse(amountController.text.trim());
                        if (amount == null || amount <= 0) return;
                        final ok = await ref
                            .read(depositControllerProvider.notifier)
                            .deposit(uid: uid, amount: amount, method: 'UPI');
                        if (ok && ctx.mounted) Navigator.pop(ctx);
                      },
                      child: state.isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Add Money', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final uid = authState.value?.uid;

    if (uid == null) {
      return const Scaffold(
        backgroundColor: _kBg,
        body: Center(child: Text('Please log in to view your wallet', style: TextStyle(color: _kTextSecondary))),
      );
    }

    final balanceAsync = ref.watch(walletBalanceProvider(uid));
    final transactionsAsync = ref.watch(walletTransactionsProvider(uid));

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(title: const Text('Wallet'), backgroundColor: _kBg, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(gradient: _kBrandGradient, borderRadius: BorderRadius.circular(18)),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Wallet Balance', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 6),
                  balanceAsync.when(
                    data: (balance) => Text('₹${balance.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
                    loading: () => const SizedBox(
                        height: 30, width: 30, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                    error: (e, _) => const Text('—', style: TextStyle(color: Colors.white, fontSize: 30)),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showAddMoneySheet(context, ref, uid),
                          icon: const Icon(Icons.add, color: Colors.white, size: 18),
                          label: const Text('Add Money', style: TextStyle(color: Colors.white)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white54),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const WithdrawScreen()),
                          ),
                          icon: const Icon(Icons.arrow_upward, color: Colors.white, size: 18),
                          label: const Text('Withdraw', style: TextStyle(color: Colors.white)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white54),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Transactions', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionScreen())),
                  child: const Text('See all', style: TextStyle(color: _kGold, fontSize: 12.5)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            transactionsAsync.when(
              loading: () => const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.redAccent)),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: Text('No transactions yet', style: TextStyle(color: _kTextSecondary))),
                  );
                }
                return Column(
                  children: transactions.take(5).map((t) => _transactionTile(t)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _transactionTile(WalletTransaction t) {
    final color = t.isCredit ? _kGreen : Colors.redAccent;
    final sign = t.isCredit ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: _kHairline)),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(t.isCredit ? Icons.arrow_downward : Icons.arrow_upward, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.description, style: const TextStyle(color: Colors.white, fontSize: 13), overflow: TextOverflow.ellipsis),
                Text('${t.createdAt.day}/${t.createdAt.month}/${t.createdAt.year}',
                    style: const TextStyle(color: _kTextSecondary, fontSize: 10.5)),
              ],
            ),
          ),
          Text('$sign₹${t.amount.toStringAsFixed(2)}', style: TextStyle(color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}