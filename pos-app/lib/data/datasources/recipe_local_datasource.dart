import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../models/intermediate_product.dart';
import '../models/menu_recipe.dart';

/// Satu datasource untuk semua tabel resep (v2).
class RecipeLocalDatasource {
  // ---------- Intermediate Products (Bahan Olahan) ----------

  Future<List<IntermediateProduct>> getAllIntermediates() async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('intermediate_products', orderBy: 'name');
    return rows.map(IntermediateProduct.fromMap).toList();
  }

  Future<void> addIntermediate(IntermediateProduct p) async {
    final db = await AppDatabase.instance.database;
    await db.insert('intermediate_products', p.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<void> updateIntermediate(IntermediateProduct p) async {
    final db = await AppDatabase.instance.database;
    await db.update('intermediate_products', p.toMap(),
        where: 'id = ?', whereArgs: [p.id]);
  }

  Future<void> deleteIntermediate(String id) async {
    final db = await AppDatabase.instance.database;
    // cascade akan ikut menghapus intermediate_recipes terkait
    await db.delete('intermediate_products',
        where: 'id = ?', whereArgs: [id]);
  }

  // ---------- Intermediate Recipes (resep bahan olahan -> bahan mentah) ----------

  Future<List<IntermediateRecipe>> getIntermediateRecipe(
      String intermediateId) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('intermediate_recipes',
        where: 'intermediate_id = ?', whereArgs: [intermediateId]);
    return rows.map(IntermediateRecipe.fromMap).toList();
  }

  Future<void> upsertIntermediateRecipe(IntermediateRecipe r) async {
    final db = await AppDatabase.instance.database;
    await db.insert('intermediate_recipes', r.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteIntermediateRecipeRow(String id) async {
    final db = await AppDatabase.instance.database;
    await db
        .delete('intermediate_recipes', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- Menu Recipes (resep menu/add-on -> komponen) ----------

  Future<List<MenuRecipe>> getMenuRecipe(String menuId) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query('menu_recipes',
        where: 'menu_id = ?', whereArgs: [menuId]);
    return rows.map(MenuRecipe.fromMap).toList();
  }

  Future<void> upsertMenuRecipe(MenuRecipe r) async {
    final db = await AppDatabase.instance.database;
    await db.insert('menu_recipes', r.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteMenuRecipeRow(String id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('menu_recipes', where: 'id = ?', whereArgs: [id]);
  }

  /// Dipakai oleh stock deduction service nanti (TAHAP 4).
  Future<List<MenuRecipe>> getMenuRecipeForTemp(
      String menuId, String temp) async {
    final db = await AppDatabase.instance.database;
    final rows = await db.query(
      'menu_recipes',
      where: 'menu_id = ? AND temperature IN (?, ?)',
      whereArgs: [menuId, temp, 'all'],
    );
    return rows.map(MenuRecipe.fromMap).toList();
  }
}
