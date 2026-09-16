import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/provider/auth_provider.dart';
import '../provider/wallet_provider.dart';
import '../repository/wallet_repository.dart';

const _kBg = Color(0xFF0F172A);
const _kCard = Color(0xFF171821);
const _kHairline = Color(0xFF2A2C38);
const _kGreen = Color(0xFF3DDC84);
const _kTextSecondary = Color(0xFF9CA0AF);

class TransactionScreen extends ConsumerWidget {
  const TransactionScreen({super.key});

  String _labelFor(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return 'Added Money';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.entryFee:
        return 'Tournament Entry Fee';
      case TransactionType.prizePayout:
        return 'Prize Winnings';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authStateProvider).value?.uid;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(title: const Text('Transaction History'), backgroundColor: _kBg, elevation: 0),
      body: uid == null
          ? const Center(child: Text('Please log in', style: TextStyle(color: _kTextSecondary)))
          : Consumer(
        builder: (context, ref, _) {
          final transactionsAsync = ref.watch(walletTransactionsProvider(uid));
          return transactionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
            data: (transactions) {
              if (transactions.isEmpty) {
                return const Center(child: Text('No transactions yet', style: TextStyle(color: _kTextSecondary)));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: transactions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final t = transactions[i];
                  final color = t.isCredit ? _kGreen : Colors.redAccent;
                  final sign = t.isCredit ? '+' : '-';
                  return Container(
                    decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: _kHairline)),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(color: color.withOpacity(0.16), shape: BoxShape.circle),
                          child: Icon(t.isCredit ? Icons.arrow_downward : Icons.arrow_upward, color: color, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_labelFor(t.type), style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text(t.description, style: const TextStyle(color: _kTextSecondary, fontSize: 11.5)),
                            ],
                          ),
                        ),
                        Text('$sign₹${t.amount.toStringAsFixed(2)}', style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}