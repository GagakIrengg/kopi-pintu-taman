import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/stock_deduction_service.dart';
import 'repository_providers.dart';

final stockDeductionServiceProvider = Provider<StockDeductionService>((ref) {
  return StockDeductionService(
    ref.read(recipeRepositoryProvider),
    ref.read(inventoryRepositoryProvider),
  );
});
