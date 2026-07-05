import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'seed_data.dart';

/// Singleton SQLite untuk semua kebutuhan offline-first.
/// Skema sudah dirancang agar mudah disinkronkan ke Supabase.
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;
  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'kpt_pos.db');
    return openDatabase(
      path,
      version: 3,
      onCreate: (db, v) async {
        await _createV1(db);
        await _createV2(db);
        await _createV3(db);
      },
      onUpgrade: (db, oldV, newV) async {
        // Migrasi bertahap. Data lama TIDAK dihapus.
        if (oldV < 2) {
          await _createV2(db);
        }
        if (oldV < 3) {
          await _createV3(db);
        }
      },
    );
  }

  /// Skema versi 1 (tabel inti yang sudah ada sebelumnya).
  Future<void> _createV1(Database db) async {
    await db.execute('''
      CREATE TABLE menu_items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        price INTEGER NOT NULL,
        category TEXT NOT NULL,
        temperature TEXT NOT NULL,
        is_available INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await db.execute('''
      CREATE TABLE inventory_items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        unit TEXT NOT NULL,
        stock REAL NOT NULL,
        min_stock REAL NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        created_at TEXT NOT NULL,
        total INTEGER NOT NULL,
        payment_method TEXT,
        cash_received INTEGER,
        customer_name TEXT,
        notes TEXT,
        status TEXT NOT NULL,
        pending_sync INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await db.execute('''
      CREATE TABLE transaction_items (
        id TEXT PRIMARY KEY,
        transaction_id TEXT NOT NULL,
        menu_item_id TEXT NOT NULL,
        menu_name TEXT NOT NULL,
        unit_price INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        temperature TEXT,
        notes TEXT,
        addon_names TEXT,
        addons_price INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE cash_sessions (
        id TEXT PRIMARY KEY,
        opened_at TEXT NOT NULL,
        opening_amount INTEGER NOT NULL,
        cashier TEXT NOT NULL
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_tx_created_at ON transactions(created_at)');
    await db.execute('CREATE INDEX idx_tx_status ON transactions(status)');
  }

  /// Skema versi 2 — fitur Resep 2 level (Bahan Olahan + Resep Menu).
  Future<void> _createV2(Database db) async {
    await db.execute('''
      CREATE TABLE intermediate_products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        unit TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE intermediate_recipes (
        id TEXT PRIMARY KEY,
        intermediate_id TEXT NOT NULL,
        ingredient_id TEXT NOT NULL,
        quantity REAL NOT NULL,
        UNIQUE(intermediate_id, ingredient_id),
        FOREIGN KEY (intermediate_id) REFERENCES intermediate_products(id) ON DELETE CASCADE,
        FOREIGN KEY (ingredient_id) REFERENCES inventory_items(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE menu_recipes (
        id TEXT PRIMARY KEY,
        menu_id TEXT NOT NULL,
        component_type TEXT NOT NULL,
        component_id TEXT NOT NULL,
        temperature TEXT NOT NULL,
        quantity REAL NOT NULL,
        UNIQUE(menu_id, component_type, component_id, temperature),
        FOREIGN KEY (menu_id) REFERENCES menu_items(id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_int_recipe_int ON intermediate_recipes(intermediate_id)');
    await db.execute(
        'CREATE INDEX idx_menu_recipe_menu ON menu_recipes(menu_id)');
  }

  /// Skema versi 3 — fitur Batalkan Pesanan (void).
  /// Tambah 4 kolom di tabel transactions. Pakai ALTER TABLE supaya
  /// data lama AMAN (kolom baru otomatis NULL untuk baris yang sudah ada).
  Future<void> _createV3(Database db) async {
    await db.execute(
        'ALTER TABLE transactions ADD COLUMN void_reason TEXT');
    await db.execute(
        'ALTER TABLE transactions ADD COLUMN void_note TEXT');
    await db.execute(
        'ALTER TABLE transactions ADD COLUMN voided_at TEXT');
    await db.execute(
        'ALTER TABLE transactions ADD COLUMN voided_by TEXT');
  }

  Future<void> seedIfEmpty() async {
    final db = await database;

    // ── Seed menu & inventory (hanya jika belum ada) ──────────────────
    final menuCnt = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM menu_items')) ??
        0;
    if (menuCnt == 0) {
      final batch = db.batch();
      for (final m in SeedData.menuItems) {
        batch.insert('menu_items', m.toMap());
      }
      for (final inv in SeedData.inventory) {
        batch.insert('inventory_items', inv.toMap());
      }
      await batch.commit(noResult: true);
    }

  }

  /// Helper convenience untuk reset data (debug only).
  Future<void> resetAll() async {
    final db = await database;
    await db.delete('transaction_items');
    await db.delete('transactions');
    await db.delete('cash_sessions');
  }
}