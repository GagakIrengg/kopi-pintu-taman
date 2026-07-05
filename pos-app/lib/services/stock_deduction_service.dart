import '../data/models/cart_item.dart';
import '../data/models/menu_item.dart';
import '../data/models/menu_recipe.dart';
import '../data/repositories/inventory_repository.dart';
import '../data/repositories/recipe_repository.dart';

/// Service: menghitung & menerapkan pengurangan stok bahan mentah
/// saat transaksi PAID.
///
/// Alur (sesuai DESAIN_FITUR_RESEP_V2):
///  - tiap item cart -> ambil resep menu sesuai temperature
///  - komponen 'ingredient' -> langsung akumulasi bahan mentah
///  - komponen 'intermediate' -> pecah dulu jadi bahan mentah (turun 1 level)
///  - add-on yang nempel juga diproses (punya resep sendiri)
///  - stok dikurangi, mentok di 0 (tidak minus)
class StockDeductionService {
  final RecipeRepository _recipeRepo;
  final InventoryRepository _inventoryRepo;

  StockDeductionService(this._recipeRepo, this._inventoryRepo);

  /// Map temperature MenuItem -> string yang dipakai di tabel resep.
  String _tempKey(MenuTemperature? t) => switch (t) {
        MenuTemperature.hot => RecipeTemp.hot,
        MenuTemperature.iced => RecipeTemp.iced,
        _ => RecipeTemp.all,
      };

  /// Proses 1 menu/add-on: tambahkan kebutuhan bahan mentah ke [akumulator].
  /// [tempKey] = 'hot' | 'iced' | 'all'.
  Future<void> _accumulate(
    String menuId,
    String tempKey,
    int porsi,
    Map<String, double> akumulator,
  ) async {
    // Ambil resep yang cocok untuk temperature ini ATAU 'all'.
    final rows =
        await _recipeRepo.getMenuRecipeForTemp(menuId, tempKey);

    for (final r in rows) {
      final totalQty = r.quantity * porsi;

      if (r.componentType == RecipeComponentType.ingredient) {
        akumulator.update(
          r.componentId,
          (v) => v + totalQty,
          ifAbsent: () => totalQty,
        );
      } else {
        // intermediate -> pecah jadi bahan mentah (level 2 -> level 1)
        final subRecipe =
            await _recipeRepo.getIntermediateRecipe(r.componentId);
        for (final s in subRecipe) {
          final need = s.quantity * totalQty;
          akumulator.update(
            s.ingredientId,
            (v) => v + need,
            ifAbsent: () => need,
          );
        }
      }
    }
  }

  /// Hitung total kebutuhan bahan mentah untuk seluruh cart.
  /// Return: map ingredientId -> jumlah yang dibutuhkan.
  Future<Map<String, double>> computeUsage(List<CartItem> items) async {
    final usage = <String, double>{};

    for (final c in items) {
      final tempKey = _tempKey(c.temperature);
      final porsi = c.quantity;

      // a) resep menu utama
      await _accumulate(c.menuItem.id, tempKey, porsi, usage);

      // b) resep tiap add-on yang menempel
      for (final addon in c.addons) {
        // add-on biasanya tanpa suhu -> pakai tempKey item induk;
        // getMenuRecipeForTemp sudah otomatis ikutkan 'all'.
        await _accumulate(addon.id, tempKey, porsi, usage);
      }
    }

    return usage;
  }

  /// Terapkan pengurangan stok ke DB. Mentok di 0 (tidak minus).
  /// Return: daftar ingredientId yang stoknya berubah (untuk refresh/cek).
  Future<void> applyDeduction(List<CartItem> items) async {
    final usage = await computeUsage(items);
    if (usage.isEmpty) return; // tidak ada resep -> tidak ada perubahan

    final all = await _inventoryRepo.getAll();
    for (final inv in all) {
      final need = usage[inv.id];
      if (need == null || need <= 0) continue;

      final newStock = (inv.stock - need);
      final clamped = newStock < 0 ? 0.0 : newStock;
      await _inventoryRepo.upsert(inv.copyWith(stock: clamped));
    }
  }
}
