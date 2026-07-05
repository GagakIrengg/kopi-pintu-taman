import '../datasources/transaction_local_datasource.dart';
import '../models/transaction.dart';

/// Offline-first: semua tulis ke SQLite dulu (pending_sync = 1).
/// Saat Supabase aktif, SyncService akan push & set pending_sync = 0.
class TransactionRepository {
  final TransactionLocalDatasource _local;
  TransactionRepository(this._local);

  Future<void> save(TransactionRecord tx) => _local.save(tx);

  Future<List<TransactionRecord>> heldBills() =>
      _local.getByStatus(TransactionStatus.held);

  /// Untuk Sales Report: paid + voided dalam rentang (voided ditampilkan
  /// dengan badge & dihitung terpisah).
  Future<List<TransactionRecord>> inRange(DateTime from, DateTime to) =>
      _local.getInRange(from, to);

  /// Untuk SAW / analisis penjualan: HANYA paid (voided dikecualikan).
  Future<List<TransactionRecord>> paidInRange(
          DateTime from, DateTime to) =>
      _local.getPaidInRange(from, to);

  Future<TransactionRecord?> byId(String id) => _local.getById(id);

  Future<void> delete(String id) => _local.delete(id);

  /// Batalkan transaksi (void) — tidak menghapus, tidak menyentuh stok.
  Future<void> voidTransaction({
    required String id,
    required VoidReason reason,
    required String note,
    required String by,
  }) =>
      _local.voidTransaction(
        id: id,
        reason: reason,
        note: note,
        by: by,
      );
}
