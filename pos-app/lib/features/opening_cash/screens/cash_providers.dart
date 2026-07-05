import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/cash_transaction.dart';

final cashProvider =
    StateNotifierProvider<CashNotifier, List<CashTransaction>>(
  (ref) => CashNotifier(),
);

class CashNotifier extends StateNotifier<List<CashTransaction>> {
  CashNotifier() : super([]);

  final _uuid = const Uuid();

  void addCash({
    required int amount,
    required CashType type,
    required String description,
  }) {
    final tx = CashTransaction(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
      amount: amount,
      type: type,
      description: description,
    );

    state = [...state, tx];
  }

  int get totalIn => state
      .where((e) => e.type == CashType.in_)
      .fold(0, (a, b) => a + b.amount);

  int get totalOut => state
      .where((e) => e.type == CashType.out)
      .fold(0, (a, b) => a + b.amount);
}