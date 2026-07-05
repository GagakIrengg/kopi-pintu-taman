import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../models/menu_item.dart';

class MenuLocalDatasource {
  Future<List<MenuItem>> getAll() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('menu_items', orderBy: 'category, name');
    return rows.map(MenuItem.fromMap).toList();
  }

  Future<void> add(MenuItem item) async {
    final db = await AppDatabase.instance.database;
    await db.insert(
      'menu_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> update(MenuItem item) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      'menu_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('menu_items', where: 'id = ?', whereArgs: [id]);
  }
}
