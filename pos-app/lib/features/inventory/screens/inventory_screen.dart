import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/inventory_item.dart';
import '../../../providers/data_providers.dart';
import '../../../providers/repository_providers.dart';
import '../widgets/ingredient_form_dialog.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inv = ref.watch(inventoryProvider);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Inventory',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w700)),
                    Text('Stok bahan & supply coffee shop.',
                        style: TextStyle(color: AppColors.textMuted)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _openForm(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Tambah Bahan'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: inv.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (items) {
                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada bahan. Tambah dengan tombol di atas.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  );
                }
                return Card(
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final it = items[i];
                      final (label, color) = switch (it.status) {
                        StockStatus.ok => ('Aman', AppColors.success),
                        StockStatus.low =>
                          ('Stok Rendah', AppColors.warning),
                        StockStatus.out => ('Habis', AppColors.danger),
                      };
                      return ListTile(
                        title: Text(it.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          'Stok: ${it.stock.toStringAsFixed(0)} ${it.unit} • '
                          'Min: ${it.minStock.toStringAsFixed(0)} ${it.unit}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(label,
                                  style: TextStyle(
                                      color: color,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              tooltip: 'Tambah Stok',
                              icon: const Icon(Icons.add_circle_outline,
                                  color: AppColors.coffee700),
                              onPressed: () => _restock(context, ref, it),
                            ),
                            IconButton(
                              tooltip: 'Edit',
                              icon: const Icon(Icons.edit_outlined,
                                  color: AppColors.coffee700),
                              onPressed: () =>
                                  _openForm(context, ref, existing: it),
                            ),
                            IconButton(
                              tooltip: 'Hapus',
                              icon: const Icon(Icons.delete_outline,
                                  color: AppColors.danger),
                              onPressed: () =>
                                  _confirmDelete(context, ref, it),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _restock(
      BuildContext context, WidgetRef ref, InventoryItem it) async {
    final ctrl = TextEditingController();
    final r = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Restock: ${it.name}'),
        content: TextField(
          controller: ctrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Tambah jumlah',
            suffixText: it.unit,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext)
                .pop(double.tryParse(ctrl.text.trim()) ?? 0),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
    if (r == null || r <= 0) return;
    await ref
        .read(inventoryRepositoryProvider)
        .upsert(it.copyWith(stock: it.stock + r));
    ref.invalidate(inventoryProvider);
  }

  Future<void> _openForm(BuildContext context, WidgetRef ref,
      {InventoryItem? existing}) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await showDialog<InventoryItem>(
      context: context,
      builder: (dialogContext) => IngredientFormDialog(existing: existing),
    );
    if (result == null) return;
    final repo = ref.read(inventoryRepositoryProvider);
    try {
      if (existing == null) {
        await repo.add(result);
      } else {
        await repo.upsert(result);
      }
      ref.invalidate(inventoryProvider);
      messenger.showSnackBar(SnackBar(
        content: Text(existing == null
            ? 'Bahan "${result.name}" berhasil ditambahkan.'
            : 'Bahan "${result.name}" berhasil diperbarui.'),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('Gagal menyimpan: $e'),
        backgroundColor: AppColors.danger,
      ));
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, InventoryItem it) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Bahan'),
        content: Text(
          'Yakin ingin menghapus "${it.name}"?\n'
          'Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(inventoryRepositoryProvider).delete(it.id);
    ref.invalidate(inventoryProvider);
    messenger.showSnackBar(SnackBar(
      content: Text('Bahan "${it.name}" dihapus.'),
    ));
  }
}
