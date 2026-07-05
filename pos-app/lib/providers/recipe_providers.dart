import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/intermediate_product.dart';
import '../data/models/menu_recipe.dart';
import 'repository_providers.dart';

/// Daftar semua Bahan Olahan (produk antara).
final intermediatesProvider =
    FutureProvider<List<IntermediateProduct>>((ref) async {
  return ref.watch(recipeRepositoryProvider).getAllIntermediates();
});

/// Resep sebuah Bahan Olahan (by id) -> daftar bahan mentah + takaran.
final intermediateRecipeProvider = FutureProvider.family<
    List<IntermediateRecipe>, String>((ref, intermediateId) async {
  return ref
      .watch(recipeRepositoryProvider)
      .getIntermediateRecipe(intermediateId);
});

/// Resep sebuah menu (by menu id) -> semua baris resep (semua temperature).
final menuRecipeProvider =
    FutureProvider.family<List<MenuRecipe>, String>((ref, menuId) async {
  return ref.watch(recipeRepositoryProvider).getMenuRecipe(menuId);
});
