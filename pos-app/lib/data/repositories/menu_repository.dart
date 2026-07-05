import '../datasources/menu_local_datasource.dart';
import '../models/menu_item.dart';

class MenuRepository {
  final MenuLocalDatasource _local;
  MenuRepository(this._local);

  Future<List<MenuItem>> getAll() => _local.getAll();
  Future<void> add(MenuItem item) => _local.add(item);
  Future<void> update(MenuItem item) => _local.update(item);
  Future<void> delete(String id) => _local.delete(id);
}
