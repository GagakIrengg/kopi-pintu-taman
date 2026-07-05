import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/inventory_item.dart';
import '../data/models/menu_item.dart';
import '../data/models/transaction.dart';
import 'repository_providers.dart';

final menuItemsProvider = FutureProvider<List<MenuItem>>((ref) async {
  return ref.watch(menuRepositoryProvider).getAll();
});

final inventoryProvider = FutureProvider<List<InventoryItem>>((ref) async {
  return ref.watch(inventoryRepositoryProvider).getAll();
});

final heldBillsProvider = FutureProvider<List<TransactionRecord>>((ref) async {
  return ref.watch(transactionRepositoryProvider).heldBills();
});

class DateRange {
  final DateTime from;
  final DateTime to;
  const DateRange(this.from, this.to);
}

final salesRangeProvider = StateProvider<DateRange>((_) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day - 6);
  final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
  return DateRange(start, end);
});

final salesInRangeProvider =
    FutureProvider<List<TransactionRecord>>((ref) async {
  final range = ref.watch(salesRangeProvider);
  return ref
      .watch(transactionRepositoryProvider)
      .inRange(range.from, range.to);
});
