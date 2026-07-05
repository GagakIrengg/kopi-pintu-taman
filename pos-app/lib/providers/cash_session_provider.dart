import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/models/cash_session.dart';

class CashSessionNotifier extends StateNotifier<CashSession?> {
  CashSessionNotifier() : super(null);

  void open(int amount, String cashier) {
    state = CashSession(
      id: const Uuid().v4(),
      openedAt: DateTime.now(),
      openingAmount: amount,
      cashier: cashier,
    );
  }

  void close() => state = null;
}

final cashSessionProvider =
    StateNotifierProvider<CashSessionNotifier, CashSession?>(
        (_) => CashSessionNotifier());
