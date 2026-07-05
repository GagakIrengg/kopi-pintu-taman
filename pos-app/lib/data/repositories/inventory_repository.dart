import '../datasources/inventory_local_datasource.dart';
import '../models/inventory_item.dart';

class InventoryRepository {
  final InventoryLocalDatasource _local;
  InventoryRepository(this._local);

  Future<List<InventoryItem>> getAll() => _local.getAll();
  Future<void> upsert(InventoryItem i) => _local.upsert(i);
  Future<void> add(InventoryItem i) => _local.add(i);
  Future<void> delete(String id) => _local.delete(id);
}
