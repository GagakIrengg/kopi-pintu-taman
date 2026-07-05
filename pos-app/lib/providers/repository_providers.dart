import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/inventory_local_datasource.dart';
import '../data/datasources/menu_local_datasource.dart';
import '../data/datasources/recipe_local_datasource.dart';
import '../data/datasources/transaction_local_datasource.dart';
import '../data/repositories/inventory_repository.dart';
import '../data/repositories/menu_repository.dart';
import '../data/repositories/recipe_repository.dart';
import '../data/repositories/transaction_repository.dart';

final menuRepositoryProvider =
    Provider((ref) => MenuRepository(MenuLocalDatasource()));

final inventoryRepositoryProvider =
    Provider((ref) => InventoryRepository(InventoryLocalDatasource()));

final transactionRepositoryProvider =
    Provider((ref) => TransactionRepository(TransactionLocalDatasource()));

final recipeRepositoryProvider =
    Provider((ref) => RecipeRepository(RecipeLocalDatasource()));
