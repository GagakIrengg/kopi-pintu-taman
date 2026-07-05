import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../models/inventory_item.dart';

class InventoryLocalDatasource {
  Future<List<InventoryItem>> getAll() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('inventory_items', orderBy: 'name');
    return rows.map(InventoryItem.fromMap).toList();
  }

  /// Insert atau replace. Dipakai untuk restock & edit data.
  Future<void> upsert(InventoryItem item) async {
    final db = await AppDatabase.instance.database;
    await db.insert(
      'inventory_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insert dengan abort kalau id sudah ada (untuk tambah baru).
  Future<void> add(InventoryItem item) async {
    final db = await AppDatabase.instance.database;
    await db.insert(
      'inventory_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> delete(String id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('inventory_items', where: 'id = ?', whereArgs: [id]);
  }
}
