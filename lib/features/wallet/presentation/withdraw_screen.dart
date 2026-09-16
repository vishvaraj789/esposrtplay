import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/provider/auth_provider.dart';
import '../provider/wallet_provider.dart';

const _kBg = Color(0xFF0F172A);
const _kCard = Color(0xFF171821);
const _kTextSecondary = Color(0xFF9CA0AF);

class WithdrawScreen extends ConsumerStatefulWidget {
  const WithdrawScreen({super.key});

  @override
  ConsumerState<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends ConsumerState<WithdrawScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _upiController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  Future<void> _submit(String uid, num currentBalance) async {
    if (!_formKey.currentState!.validate()) return;

    final amount = num.parse(_amountController.text.trim());
    if (amount > currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient balance')),
      );
      return;
    }

    final ok = await ref.read(withdrawControllerProvider.notifier).withdraw(
      uid: uid,
      amount: amount,
      destination: _upiController.text.trim(),
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Withdrawal successful')),
      );
      Navigator.pop(context);
    } else {
      final error = ref.read(withdrawControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Withdrawal failed: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authStateProvider).value?.uid;
    final withdrawState = ref.watch(withdrawControllerProvider);

    if (uid == null) {
      return const Scaffold(
        backgroundColor: _kBg,
        body: Center(child: Text('Please log in', style: TextStyle(color: _kTextSecondary))),
      );
    }

    final balanceAsync = ref.watch(walletBalanceProvider(uid));

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(title: const Text('Withdraw'), backgroundColor: _kBg, elevation: 0),
      body: balanceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
        data: (balance) => Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Available balance: ₹${balance.toStringAsFixed(2)}',
                    style: const TextStyle(color: _kTextSecondary, fontSize: 13)),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    labelStyle: const TextStyle(color: _kTextSecondary),
                    filled: true,
                    fillColor: _kCard,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  validator: (v) {
                    final n = num.tryParse(v?.trim() ?? '');
                    if (n == null || n <= 0) return 'Enter a valid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _upiController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'UPI ID',
                    hintText: 'yourname@upi',
                    labelStyle: const TextStyle(color: _kTextSecondary),
                    hintStyle: const TextStyle(color: _kTextSecondary),
                    filled: true,
                    fillColor: _kCard,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'UPI ID is required' : null,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF3D5A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: withdrawState.isLoading ? null : () => _submit(uid, balance),
                    child: withdrawState.isLoading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Withdraw', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}