import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../models/transaction.dart';

class TransactionLocalDatasource {
  Future<void> save(TransactionRecord tx) async {
    final db = await AppDatabase.instance.database;
    await db.transaction((txn) async {
      await txn.insert('transactions', tx.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      await txn.delete('transaction_items',
          where: 'transaction_id = ?', whereArgs: [tx.id]);
      for (final it in tx.items) {
        await txn.insert('transaction_items', it.toMap(tx.id));
      }
    });
  }

  Future<List<TransactionRecord>> getByStatus(TransactionStatus s) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('transactions',
        where: 'status = ?',
        whereArgs: [s.name],
        orderBy: 'created_at DESC');
    return _hydrate(db, rows);
  }

  /// Untuk Sales Report: ambil transaksi PAID *dan* VOIDED dalam rentang.
  /// Voided tetap diambil agar bisa ditampilkan (badge) & dihitung terpisah.
  /// Held tidak diikutkan (belum jadi transaksi).
  Future<List<TransactionRecord>> getInRange(
      DateTime from, DateTime to) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'transactions',
      where:
          "status IN ('paid','voided') AND created_at BETWEEN ? AND ?",
      whereArgs: [from.toIso8601String(), to.toIso8601String()],
      orderBy: 'created_at DESC',
    );
    return _hydrate(db, rows);
  }

  /// Khusus sumber data untuk SAW / analisis penjualan:
  /// HANYA transaksi paid (voided dikecualikan demi integritas data).
  Future<List<TransactionRecord>> getPaidInRange(
      DateTime from, DateTime to) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'transactions',
      where: "status = 'paid' AND created_at BETWEEN ? AND ?",
      whereArgs: [from.toIso8601String(), to.toIso8601String()],
      orderBy: 'created_at DESC',
    );
    return _hydrate(db, rows);
  }

  Future<TransactionRecord?> getById(String id) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('transactions',
        where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return (await _hydrate(db, rows)).first;
  }

  Future<void> delete(String id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  /// Tandai transaksi sebagai voided (TIDAK menghapus, TIDAK menyentuh stok).
  /// Hanya update kolom status + kolom void_*.
  Future<void> voidTransaction({
    required String id,
    required VoidReason reason,
    required String note,
    required String by,
  }) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      'transactions',
      {
        'status': TransactionStatus.voided.name,
        'void_reason': reason.name,
        'void_note': note,
        'voided_at': DateTime.now().toIso8601String(),
        'voided_by': by,
        'pending_sync': 1,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<TransactionRecord>> _hydrate(
      Database db, List<Map<String, Object?>> rows) async {
    final result = <TransactionRecord>[];
    for (final r in rows) {
      final items = (await db.query('transaction_items',
              where: 'transaction_id = ?', whereArgs: [r['id']]))
          .map(TransactionItem.fromMap)
          .toList();
      result.add(TransactionRecord.fromMap(r, items));
    }
    return result;
  }
}
