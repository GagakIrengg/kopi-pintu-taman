import '../datasources/recipe_local_datasource.dart';
import '../models/intermediate_product.dart';
import '../models/menu_recipe.dart';

class RecipeRepository {
  final RecipeLocalDatasource _local;
  RecipeRepository(this._local);

  // Bahan Olahan
  Future<List<IntermediateProduct>> getAllIntermediates() =>
      _local.getAllIntermediates();
  Future<void> addIntermediate(IntermediateProduct p) =>
      _local.addIntermediate(p);
  Future<void> updateIntermediate(IntermediateProduct p) =>
      _local.updateIntermediate(p);
  Future<void> deleteIntermediate(String id) =>
      _local.deleteIntermediate(id);

  // Resep Bahan Olahan
  Future<List<IntermediateRecipe>> getIntermediateRecipe(String id) =>
      _local.getIntermediateRecipe(id);
  Future<void> upsertIntermediateRecipe(IntermediateRecipe r) =>
      _local.upsertIntermediateRecipe(r);
  Future<void> deleteIntermediateRecipeRow(String id) =>
      _local.deleteIntermediateRecipeRow(id);

  // Resep Menu
  Future<List<MenuRecipe>> getMenuRecipe(String menuId) =>
      _local.getMenuRecipe(menuId);
  Future<void> upsertMenuRecipe(MenuRecipe r) =>
      _local.upsertMenuRecipe(r);
  Future<void> deleteMenuRecipeRow(String id) =>
      _local.deleteMenuRecipeRow(id);
  Future<List<MenuRecipe>> getMenuRecipeForTemp(
          String menuId, String temp) =>
      _local.getMenuRecipeForTemp(menuId, temp);
}
