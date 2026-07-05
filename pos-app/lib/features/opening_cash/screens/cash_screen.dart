import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/cash_transaction.dart';
import '../../opening_cash/screens/cash_providers.dart';

class CashScreen extends ConsumerStatefulWidget {
  const CashScreen({super.key});

  @override
  ConsumerState<CashScreen> createState() => _CashScreenState();
}

class _CashScreenState extends ConsumerState<CashScreen> {
  final amountCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  CashType selectedType = CashType.in_;

  @override
  Widget build(BuildContext context) {
    final cash = ref.watch(cashProvider);
    final notifier = ref.read(cashProvider.notifier);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// INPUT FORM
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nominal',
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(
                labelText: 'Keterangan',
              ),
            ),

            const SizedBox(height: 8),

            /// TYPE SELECT
            Row(
              children: [
                Radio<CashType>(
                  value: CashType.in_,
                  groupValue: selectedType,
                  onChanged: (v) {
                    setState(() => selectedType = v!);
                  },
                ),
                const Text("Kas Masuk"),

                Radio<CashType>(
                  value: CashType.out,
                  groupValue: selectedType,
                  onChanged: (v) {
                    setState(() => selectedType = v!);
                  },
                ),
                const Text("Kas Keluar"),
              ],
            ),

            const SizedBox(height: 10),

            /// ADD BUTTON
            Align(
              alignment: Alignment.centerRight,
              child: FloatingActionButton(
                onPressed: () {
                  notifier.addCash(
                    amount: int.tryParse(amountCtrl.text) ?? 0,
                    type: selectedType,
                    description: descCtrl.text,
                  );

                  amountCtrl.clear();
                  descCtrl.clear();
                },
                child: const Icon(Icons.add),
              ),
            ),

            const Divider(),

            /// LIST
            Expanded(
              child: ListView.builder(
                itemCount: cash.length,
                itemBuilder: (_, i) {
                  final c = cash[i];

                  return ListTile(
                    title: Text(c.description),
                    subtitle: Text(c.type == CashType.in_
                        ? "Kas Masuk"
                        : "Kas Keluar"),
                    trailing: Text("${c.amount}"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}